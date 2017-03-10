# frozen_string_literal: true
require 'spec_helper'

RSpec.describe OpenGov::Util::Thread, type: :library do
  THREAD = OpenGov::Util::Thread

  describe '.main' do
    it 'returns the main thread wrapped in a OpenGov::Util::Thread' do
      expect(THREAD.main).to eq(THREAD.new(Thread.main))
    end
  end

  describe '.current' do
    it 'returns the current thread wrapped in a OpenGov::Util::Thread' do
      expect(THREAD.current).to eq(THREAD.new(Thread.current))
    end
  end

  describe '#initialize' do
    it 'can take a Thread object' do
      expect { THREAD.new(Thread.current) }.not_to raise_error
    end

    it 'can take a block with args' do
      expect { THREAD.new('foo') { |str| str + 'd' } }.not_to raise_error
    end

    it 'can take a block without args' do
      expect { THREAD.new { 'this does not do much' } }.not_to raise_error
    end

    it '--without a block -- requires a Thread object' do
      expect { THREAD.new }.to raise_error(ArgumentError)
    end

    it '--without a block -- will only take a Thread object' do
      expect { THREAD.new('foo') }.to raise_error(ArgumentError)
    end

    it '--without a block -- will only take one Thread object' do
      expect { THREAD.new(Thread.current, Thread.current) }.to raise_error(ArgumentError)
    end
  end

  describe '#lineage' do
    it 'can walk up the parents' do
      THREAD.current[:foo] = 0

      THREAD.new do
        THREAD.current[:foo] = 1

        THREAD.new do
          THREAD.current[:foo] = 2

          THREAD.new do
            THREAD.current[:foo] = 3

            expect(THREAD.current.lineage.map { |thr| thr[:foo] }).to eq([3, 2, 1, 0])
          end
        end
      end
    end
  end
end
