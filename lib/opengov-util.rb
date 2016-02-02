module OpenGov
  module Util
    autoload 'Errors', 'opengov-util/errors'
  end
end

require_relative 'opengov-util/default_hash'
require_relative 'opengov-util/thread_pool'
require_relative 'opengov-util/dynamo_db'
