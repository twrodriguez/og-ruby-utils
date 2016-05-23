class OpenGov::Util::DefaultHash < ::Hash
  def self.new(default = nil, &block)
    return super if block_given? && !default.nil?

    if default.is_a?(Class) && default.respond_to?(:new)
      block ||= ->(h, k) { h[k] = default.new }
    else
      block ||= lambda do |h, k|
        begin
          h[k] = default.dup
        rescue
          h[k] = default
        end
      end
    end

    super(&block)
  end
end
