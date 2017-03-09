# frozen_string_literal: true
require 'uri'
require_relative 'collection'

module OpenGov::Util::QueryParams
  module_function

  def encode(params = {})
    return '' if params.empty?

    new_params = {}
    params.each do |key, val|
      key = key.to_s
      if val.is_any_of?(Array, Set, Enumerator, OpenGov::Util::Collection)
        key += '[]' unless key.end_with?('[]')
        val = val.to_a
      end
      new_params[key] = val
    end

    "?#{::URI.encode_www_form(new_params)}"
  end

  def decode(query_string, hsh = {})
    return if query_string.nil? || query_string.empty?

    query_string = URI.unescape(query_string.sub(/\A\?/, ''))
    query_string.split('&').each_with_object(hsh) do |val, params|
      key, val = val.split('=', 2)
      if key.end_with?('[]') || params[key].is_a?(Array)
        key = key[0...-2]
        params[key] ||= []
        params[key] << val
      elsif params.key?(key)
        params[key] = [params]
      else
        params[key] = val
      end
    end
  end
end
