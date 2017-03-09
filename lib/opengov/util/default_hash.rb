# frozen_string_literal: true
class OpenGov::Util::DefaultHash < ::Hash
  def self.new(default = nil, &block)
    return super if block_given? && !default.nil?

    block ||= if default.is_a?(Class) && default.respond_to?(:new)
                ->(h, k) { h[k] = default.new }
              else
                ->(h, k) { h[k] = default.dup rescue default } # rubocop:disable Style/RescueModifier
              end

    super(&block)
  end
end
