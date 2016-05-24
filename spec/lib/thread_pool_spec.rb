require 'spec_helper'

RSpec.describe OpenGov::Util::ThreadPool, type: :library do
  let(:thread_pool) { OpenGov::Util::ThreadPool.new }
  let(:thread_pool_no_concurrency) { OpenGov::Util::ThreadPool.new(1) }

  describe '#initialize' do
    it 'runs things in parallel' do
      timer = Time.now

      returns = {}

      3.times do |i|
        thread_pool.push do
          sleep(i / 10.0 + 0.1)
          returns[i] = i + 1
        end
      end

      thread_pool.push { returns[5] = 'huzzah' }
      expect(returns).to eq({})
      thread_pool.join

      elapsed = Time.now - timer

      expect(returns).to eq(0 => 1, 1 => 2, 2 => 3, 5 => 'huzzah')
      expect(elapsed).to be < 0.5
    end
  end
end
