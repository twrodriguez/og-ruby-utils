# rubocop:disable ModuleLength
#
# Amazon DynamoDB Data Types:
#
# B     A Binary data type.         Type: Blob
# BOOL  A Boolean data type.        Type: Boolean
# BS    A Binary Set data type.     Type: array of Blobs
# L     A List of attribute values. Type: array of AttributeValue objects
# M     A Map of attribute values.  Type: String to AttributeValue object map
# N     A Number data type.         Type: Numeric
# NS    A Number Set data type.     Type: array of Numerics
# NULL  A Null data type.           Type: Boolean
# S     A String data type.         Type: String
# SS    A String Set data type.     Type: array of Strings
#
class OpenGov::Util::DynamoDb
  attr_reader :table, :throughput

  def self.extended(_klass)
    require_relative 'fog_dynamodb_20120810'
  end

  def self.included(_klass)
    require_relative 'fog_dynamodb_20120810'
  end

  ALLOW_ARCHITECT = Rails.env.in?(%w(development travis test)) || ENV['DB_ARCHITECT'] == 'true'

  #################
  # DB Operations #
  #################

  #
  # Generate a new client
  #
  def initialize(params = nil)
    params ||= Settings.aws
    params = params.symbolize_keys # Yes, make a copy
    Fog::AWS::DynamoDB.new(params.slice(*%i(host port scheme aws_access_key_id aws_secret_access_key region)))
  end

  #
  # Idempotent ensure
  #
  def ensure_table_exists(params = nil)
    return true unless ALLOW_ARCHITECT

    # Check cache
    return @table_exists if @table_exists

    # List current tables
    connection = new_db_connection(params)
    resp = connection.list_tables # NOTE: Does not take into account pagination from AWS's api
    @table_exists ||= resp.body['TableNames'].include?(table)
    return @table_exists if @table_exists

    # Iff doesn't exist, create
    connection.create_table(table, schema, throughput, attribute_definitions)
    @table_exists = true
  end

  #
  # Idempotent Table Throughput Update
  #
  def ensure_throughput_updated(params = nil)
    return @throughput_uptodate if @throughput_uptodate && Rails.env == 'development'
    ensure_table_exists(params)

    # List current tables
    connection = new_db_connection(params)

    resp = connection.describe_table(table)
    throughput = resp.body['Table']['ProvisionedThroughput']

    # If Throughput values aren't the same
    if throughput & self.throughput != self.throughput
      # Iff doesn't exist, create
      connection.update_table(table, self.throughput)
    end
    @throughput_uptodate = true
  end

  #
  # Make formatted query call
  #
  def db_query(key_conditions)
    connection = new_db_connection

    resp = aws_retry_handler do
      connection.query(table, @hash_attribute_name, 'KeyConditions' => key_conditions,
                                                    'ReturnConsumedCapacity' => 'TOTAL')
    end

    resp.body
  end

  #
  # Make formatted read for multiple items
  #
  def db_batch_read(item_keys)
    connection = new_db_connection

    resp = aws_retry_handler do
      connection.batch_get_item(table => { 'Keys' => item_keys })
    end

    resp.body
  end

  #
  # Make formatted read for single item
  #
  def db_read(item_key)
    connection = new_db_connection

    resp = aws_retry_handler do
      connection.get_item(table, item_key, 'AttributesToGet' => @attribute_types.keys,
                                           'ReturnConsumedCapacity' => 'TOTAL')
    end

    resp.body
  end

  #
  # Make formatted write for single item
  #
  def db_write(item_key, original_item, update_data)
    connection = new_db_connection
    update_attributes = {}

    update_data.each do |k, value|
      next unless @attribute_types.key?(k) && !key_attr?(k)
      next if original_item[k] == value # No need to update if it hasn't changed
      update_attributes[k] = {
        'Action' => 'PUT',
        'Value' => construct_update_data(@attribute_types[k], value)
      }
    end

    if update_attributes.size > 0
      if @attribute_types.include? 'updated_at'
        update_attributes['updated_at'] = {
          'Action' => 'PUT',
          'Value' => {
            @attribute_types['updated_at'] => utc_timestamp
          }
        }
      end

      resp = aws_retry_handler do
        connection.update_item(table, item_key, update_attributes, 'ReturnValues' => 'ALL_NEW',
                                                                   'ReturnConsumedCapacity' => 'TOTAL')
      end

      resp.body
    else
      original_item
    end
  end

  #######################
  # Simple API requests #
  #######################

  #
  # Read single item
  #
  def find(*args)
    # Ensure Table Exists & Throughput it as it's latest level
    ensure_throughput_updated

    # Make GetItem request
    item_key = create_item_key(*args)
    body = db_read(item_key)

    # Return Value
    clean_response_body(body)
  end

  #
  # Destroy single item
  #
  def destroy(*args)
    # Ensure Table Exists & Throughput it as it's latest level
    ensure_throughput_updated

    # Make DeleteItem request
    connection = new_db_connection
    item_key = create_item_key(*args)

    aws_retry_handler do
      connection.delete_item(table, item_key, {})
    end
  end

  ###########
  # Helpers #
  ###########

  def schema
    @schema ||= @key_attributes.map do |attr_name|
      {
        'AttributeName' => attr_name,
        'KeyType' => attr_name == @hash_attribute_name ? 'HASH' : 'RANGE'
      }
    end
  end

  def attribute_definitions
    @attribute_definitions ||= @key_attributes.map do |attr_name|
      {
        'AttributeName' => attr_name,
        'AttributeType' => @attribute_types[attr_name]
      }
    end
  end

  def key_attr?(attr_name)
    @key_attributes.include? attr_name
  end

  def utc_timestamp
    Time.now.utc.to_s
  end

  # Override this function if you need to construct a custom hash key
  def create_hash_key(key)
    key
  end

  # Override this function if you need to construct a custom range key
  def create_range_key(key)
    key
  end

  def create_item_key(*args)
    item_key = {
      @hash_attribute_name => {
        @attribute_types[@hash_attribute_name] => create_hash_key(*args)
      }
    }
    if @range_attribute_name
      item_key[@range_attribute_name] = {
        @attribute_types[@range_attribute_name] => create_range_key(*args)
      }
    end
    item_key
  end

  #
  # DynamoDB requires JSON-specific objects (Lists, Maps) to be type-annotated, so instead of:
  #
  #   {"String": ["array", "of", "values"]}
  #
  # It needs to be:
  #
  #   {
  #     "M": {
  #       "String": {
  #         "L": [
  #           {"S": "array"},
  #           {"S": "of"},
  #           {"S": "values"}
  #         ]
  #       }
  #     }
  #   }
  #
  def construct_update_data(type, value)
    return { 'NULL' => true } if value.nil?

    type = [*type]
    if type.size > 1
      case type[0]
      when 'M'
        fail TypeError unless value.is_a? Hash
        ret = {}
        value.each_pair { |k, v| ret[k] = construct_update_data(type[1..-1], v) }
        { type[0] => ret }
      when 'L', 'SS', 'NS', 'BS'
        fail TypeError unless value.is_a? Array
        { type[0] => value.map { |v| construct_update_data(type[1..-1], v) } }
      else
        { type[0] => value }
      end
    else
      { type[0] => value }
    end
  end

  #
  # Reduce to simple return value
  #
  def clean_response_body(body)
    return nil unless body
    if body['Responses'] && body['Responses'][table]
      body['Responses'][table].map(&method(:clean_item))
    elsif body['Items']
      body['Items'].map(&method(:clean_item))
    elsif body['Item'] || body['Attributes']
      clean_item(body['Item'] || body['Attributes'])
    elsif body.key?(@hash_attribute_name)
      body
    end
  end

  #
  # Best Practice for AWS error handling
  #
  def aws_retry_handler(retries_left = 3)
    retries_left -= 1
    yield
  rescue ::Excon::Errors::Conflict
    warn 'Got "Conflict", waiting for things to settle down...'
    sleep 5
    retries_left <= 0 ? raise : retry
  rescue ::Excon::Errors::ServiceUnavailable
    warn 'Got "ServiceUnavailable", retrying...'
    sleep 2
    retries_left <= 0 ? raise : retry
  rescue ::Excon::Errors::NotFound
    nil
  rescue ::Excon::Errors::BadRequest => err
    if err.response && err.response.headers['Content-Type'] =~ /json/
      begin
        body = MultiJson.load(err.response.body)
        case (body['__type'] && body['__type'].split('#')[-1])
        when 'ProvisionedThroughputExceededException', 'ThrottlingException'
          sleep 1
          retries_left <= 0 ? fail : retry
        else
          fail
        end
      rescue
      end
      raise err
    end
  end

  #
  # Pass-through for all other Fog::AWS::DynamoDB functions
  #
  def method_missing(fn, *args, &block)
    if new_db_connection.respond_to? fn
      new_db_connection.send(fn, *args, &block)
    else
      fail NoMethodError, "Method name '#{fn}' not found"
    end
  end

  private

  #
  # Remove DynamoDB-specific cruft
  #
  def clean_item(item)
    new_item = {}
    # Get the value of the first key/value pair in the single-element hash
    item.each { |k, v| new_item[k] = clean_value(v) }
    new_item
  end

  #
  # Recursively clean type annotations from DynamoDB return
  #
  def clean_value(val_meta)
    return val_meta unless val_meta.is_a? Hash
    type = val_meta.first.first
    value = val_meta.first.last
    case type
    when 'L'
      value.map(&method(:clean_value))
    when 'M'
      ret = {}
      value.each { |k, v| ret[k] = clean_value(v) }
      ret
    when 'NULL'
      nil
    else
      value
    end
  end
end
# rubocop:enable ModuleLength
