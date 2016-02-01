module RooUtils
  module_function

  def flatten_nested(original_hsh, key_joiner = '__')
    new_hsh = original_hsh.dup
    new_hsh.keys.each do |base_key|
      next unless new_hsh[base_key].is_a?(Hash)
      new_nested_hsh = flatten_nested(new_hsh[base_key], key_joiner)
      new_nested_hsh.each_pair do |k, v|
        new_hsh["#{base_key}#{key_joiner}#{k}"] = v
      end
      new_hsh.delete(base_key)
    end
    new_hsh
  end

  # Convert a matrix to a hash
  def ingest_matrix(matrix, hsh, primary_key = nil, unique_keys = true)
    keys = matrix[0]
    primary_key = keys.index(primary_key) if primary_key.is_a? String
    case primary_key
    when Proc
      get_key = primary_key
    when Integer
      get_key = ->(row) { row[primary_key] }
    else # default
      get_key = ->(row) { row[0] }
    end

    matrix[1..-1].each do |row|
      id = get_key[row].downcase
      temp = {}
      row.each_with_index { |val, i| temp[keys[i]] = val }
      if unique_keys
        hsh[id] ||= temp
      else
        hsh[id] ||= []
        hsh[id] << temp
      end
    end
  end

  # This assumes that a file has the first row as column headers,
  # then uses the first column as primary keys.
  def ingest_file(filepath, primary_key = nil, unique_keys = true)
    hsh = {}
    filepath = filepath.to_s
    matrix = ::Roo::Spreadsheet.open(filepath).to_a
    ingest_matrix(matrix, hsh, primary_key, unique_keys)
    hsh
  end
end
