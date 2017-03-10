# frozen_string_literal: true
require 'forwardable'

class OpenGov::Util::Thread
  class << self
    include Forwardable
    extend Forwardable

    def_delegators(Thread, *(Thread.methods(false) - [:new]))

    def current
      new(Thread.current)
    end

    def main
      new(Thread.main)
    end
  end

  attr_reader :thread

  def_delegators :@thread, *Thread.instance_methods(false)

  def ==(other)
    other.is_a?(OpenGov::Util::Thread) && other.thread == @thread
  end

  def initialize(*args)
    @thread = if block_given?
                Thread.new(Thread.current, *args) do |parent, *passed_args|
                  Thread.current.instance_variable_set(:@parent, parent)
                  yield(*passed_args)
                end
              elsif args.size == 1 && args.first.is_a?(Thread)
                args.first
              else
                raise ArgumentError, 'either the first (and only) argument must be a Thread object or a block must be passed'
              end
  end

  def lineage
    if block_given?
      current = @thread
      while current
        yield current
        current = current.instance_variable_get(:@parent)
      end
    else
      enum_for(:lineage)
    end
  end
end
