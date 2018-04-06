# frozen_string_literal: true

require 'concurrent'

class OpenGov::Util::ThreadPool
  class << self
    def concurrency_limit
      @concurrency_limit ||= 256
    end

    def concurrency_limit=(val)
      @concurrency_limit = [val.to_i, 1].max
    end
  end

  #
  # Thread Pool methods
  #
  attr_reader :limit

  def initialize(concurrency_limit = nil)
    @pool = []
    # Squeeze limit between 1 and global @concurrency_limit
    @limit = if concurrency_limit
               [[concurrency_limit.to_i, self.class.concurrency_limit.to_i].min, 1].max
             else
               self.class.concurrency_limit
             end
  end

  def push(*args, &block)
    raise 'No block provided' unless block_given?
    if @limit == 1
      yield(*args)
    else
      @pool << Thread.new(*args, &block)
      join if @pool.size >= @limit.to_i
    end
  end

  def each(&block)
    @pool.each(&block)
  end

  def join
    @pool.each(&:join)
    @pool.each(&:exit)
    @pool.clear
  end

  #
  # Class Helpers
  #
  class << self
    def parallel(items, opts = {}, &block)
      _parallel_exec(items, { return_key: :id.to_proc }.merge(opts), &block).each.to_h
    end

    def parallel_map(items, opts = {}, &block)
      thread_returns = _parallel_exec(items, opts - [:return_key], &block)
      return [] if thread_returns.empty?
      Array.new(thread_returns.size) { |i| thread_returns[i] }
    end
    alias pmap parallel_map

    private

    def _parallel_exec(items, opts = {})
      raise 'No block provided' unless block_given?
      opts = {
        timeout: 5,
        capture_timeout: true,
        concurrency_limit: concurrency_limit
      }.merge(opts)

      thread_returns = Concurrent::Map.new
      pool = new(opts[:concurrency_limit])
      items.each_with_index do |item, index|
        return_key = if opts[:return_key].is_a? Proc
                       opts[:return_key].call(item)
                     else
                       index
                     end

        pool.push do
          begin
            Timeout.timeout(opts[:timeout]) do
              thread_returns[return_key] = yield(item)
            end
          rescue Timeout::Error => e
            raise unless opts[:capture_timeout]
            thread_returns[return_key] = e
          end
        end
      end
      pool.join
      thread_returns
    end
  end
end
