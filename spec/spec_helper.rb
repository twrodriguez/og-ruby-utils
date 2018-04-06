# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

require 'rspec'
require 'opengov/util'

RSpec.configure do |config|
  config.order = 'random'
  config.mock_with :rspec do |c|
    c.syntax = %i[should expect]
  end
end
