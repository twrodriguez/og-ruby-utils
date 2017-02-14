class OpenGov::Util::LookupHash < ::Hash
  def to_proc
    ->(*args) { dig(*args) }
  end
end
