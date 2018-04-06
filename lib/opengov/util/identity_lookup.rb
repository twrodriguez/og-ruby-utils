# frozen_string_literal: true

require_relative 'lookup_hash'

class OpenGov::Util::IdentityLookup < OpenGov::Util::LookupHash
  def initialize(*)
    super
    return if block_given?
    self.default_proc = ->(hsh, key) { hsh[key] = key } # h[a] == a
  end
end
