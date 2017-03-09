# frozen_string_literal: true
require 'spec_helper'

RSpec.describe OpenGov::Util::DefaultHash, type: :library do
  describe '.new' do
    it 'does not need an argument' do
      d_hash = OpenGov::Util::DefaultHash.new
      expect(d_hash[0]).to eq(nil)
    end

    it 'can use a class as a default' do
      d_hash = OpenGov::Util::DefaultHash.new Array
      expect(d_hash[0]).to eq([])
    end

    it 'can use an object example as a default' do
      d_hash = OpenGov::Util::DefaultHash.new []
      expect(d_hash[0]).to eq([])
    end

    it 'can use a non-dupable object as a default' do
      d_hash = OpenGov::Util::DefaultHash.new 0
      expect(d_hash[0]).to eq(0)
    end

    it 'can accept a block for default' do
      d_hash = OpenGov::Util::DefaultHash.new { |h, k| h[k] = {} }
      expect(d_hash[0]).to eq({})
    end

    it 'raises an exception if it receives a block and an argument' do
      expect { OpenGov::Util::DefaultHash.new(0) { |h, k| h[k] = 0 } }.to raise_exception(ArgumentError)
    end
  end

  describe '#is_a?' do
    it 'operates as a hash should' do
      expect(OpenGov::Util::DefaultHash.new.is_a?(Hash)).to be
    end
  end

  describe '#[]' do
    it 'operates as a default hash should' do
      d_hash = OpenGov::Util::DefaultHash.new []
      d_hash[:foo].push(9)
      expect(d_hash[:foo]).to eq([9])
    end
  end
end
