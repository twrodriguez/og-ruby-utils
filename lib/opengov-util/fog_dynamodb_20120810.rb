# Need to call .new with valid parameters to trigger the dynamic includes to
# define modules & methods
begin
  Fog::AWS::DynamoDB.new(
    aws_access_key_id: '',
    aws_secret_access_key: ''
  )
rescue
end

module Fog
  module AWS
    class DynamoDB
      class Real
        def create_table(table_name, key_schema, provisioned_throughput, attribute_definitions)
          body = {
            'AttributeDefinitions'  => attribute_definitions,
            'KeySchema'             => key_schema,
            'ProvisionedThroughput' => provisioned_throughput,
            'TableName'             => table_name
          }

          request(
            body: Fog::JSON.encode(body),
            headers: { 'x-amz-target' => 'DynamoDB_20120810.CreateTable' },
            idempotent: true
          )
        end
      end
    end
  end
end
