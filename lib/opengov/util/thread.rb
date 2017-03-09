# frozen_string_literal: true
class OpenGov::Util::Thread < ::Thread
  attr_reader :parent

  def initialize(*)
    @parent = Thread.current
    super
  end

  def lineage
    if block_given?
      current = self
      while current
        yield current
        current = current.parent
      end
    else
      enum_for(:lineage)
    end
  end
end
