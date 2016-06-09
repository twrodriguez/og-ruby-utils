require 'spec_helper'

RSpec.describe OpenGov::Util::ThreadPool, type: :library do
  let(:thread_pool) { OpenGov::Util::ThreadPool.new }
  let(:limited_thread_pool) { OpenGov::Util::ThreadPool.new(2) }
  let(:thread_pool_no_concurrency) { OpenGov::Util::ThreadPool.new(1) }

  describe '.parallel_map' do
    it 'returns things in the same order they were passed in' do
      items = 1..10
      seq_items = items.map { |n| n * 2 }
      parallel_items = OpenGov::Util::ThreadPool.parallel_map(items) { |n| n * 2 }
      expect(seq_items).to eq(parallel_items)
    end
  end

  describe '.parallel' do
    it 'returns a hash of items based on a custom block' do
      items = 1..10
      seq_items = items.each_with_object({}) { |n,memo| memo[n] = n * 2 }
      parallel_items = OpenGov::Util::ThreadPool.parallel(items, return_key: -> n { n }) { |n| n * 2 }
      expect(seq_items).to eq(parallel_items)
    end
  end

  describe '#initialize' do
    it 'runs things in parallel' do
      timer = Time.now

      returns = {}

      10.times do |i|
        thread_pool.push do
          sleep(0.1)
          returns[i] = i + 1
        end
      end

      thread_pool.push { returns[-1] = 'huzzah' }
      expect(returns.size).not_to eq(11)
      thread_pool.join

      elapsed = Time.now - timer

      expect(returns.size).to eq(11)
      expect(returns).to include(0 => 1, 1 => 2, 2 => 3, -1 => 'huzzah')
      expect(elapsed).to be < 0.5
    end

    it 'runs things in a limited pool' do
      timer = Time.now

      returns = {}

      10.times do |i|
        limited_thread_pool.push do
          sleep(0.1)
          returns[i] = i + 1
        end
      end

      thread_pool.push { returns[-1] = 'huzzah' }
      expect(returns.size).not_to eq(11)
      thread_pool.join

      elapsed = Time.now - timer

      expect(returns.size).to eq(11)
      expect(returns).to include(0 => 1, 1 => 2, 2 => 3, -1 => 'huzzah')
      expect(elapsed).to be > 0.5
      expect(elapsed).to be < 1.0
    end

    it 'runs things without spinning off threads' do
      timer = Time.now

      returns = {}

      10.times do |i|
        thread_pool_no_concurrency.push do
          sleep(0.1)
          returns[i] = i + 1
        end
      end

      thread_pool.push { returns[-1] = 'huzzah' }
      expect(returns).not_to eq({})
      thread_pool.join

      elapsed = Time.now - timer

      expect(returns.size).to eq(11)
      expect(returns).to include(0 => 1, 1 => 2, 2 => 3, -1 => 'huzzah')
      expect(elapsed).to be > 0.8
    end

    it 'can overrides the default concurrency_limit' do
      before_val = OpenGov::Util::ThreadPool.concurrency_limit
      OpenGov::Util::ThreadPool.concurrency_limit = 42
      expect(thread_pool.instance_variable_get('@limit')).to eq(42)

      OpenGov::Util::ThreadPool.concurrency_limit = before_val
    end
  end
end
