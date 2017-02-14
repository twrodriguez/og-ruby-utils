class OpenGov::Util::NestedHash < ::Hash
  def initialize(*)
    super
    self.default_proc = ->(hsh, key) { hsh[key] = OpenGov::Util::NestedHash.new }
  end
end
