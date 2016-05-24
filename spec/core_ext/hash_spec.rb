require 'spec_helper'

RSpec.describe Hash, type: :library do
  let(:hash) do
    {
      'a' => 1,
      'b' => 2,
      c: 3,
      'd' => {
        'e' => 4
      }
    }
  end

  describe '#symbolize_keys' do
    it 'works as expected' do
      symbolized_hash = hash.symbolize_keys

      expect(symbolized_hash).not_to eq(hash)
      expect(symbolized_hash.keys).to contain_exactly(*%i(a b c d))
      expect(symbolized_hash[:d]).to eq('e' => 4)
    end
  end

  describe '#select_keys' do
    it 'fails as expected' do
      expect{ hash.select_keys(['a'], &:nil?) }.to raise_exception(ArgumentError)
      expect{ hash.select_keys }.to raise_exception(ArgumentError)
    end

    it 'works as expected' do
      trimmed_hash = hash & %w(a b z)

      expect(trimmed_hash).not_to eq(hash)
      expect(trimmed_hash.keys).to contain_exactly('a', 'b')
      expect(trimmed_hash['d']).to be_nil
    end

    it 'works as expected with a Regexp' do
      trimmed_hash = hash & /a|c/

      expect(trimmed_hash).not_to eq(hash)
      expect(trimmed_hash.keys).to contain_exactly('a', :c)
      expect(trimmed_hash['d']).to be_nil
    end

    it 'works as expected with a block' do
      trimmed_hash = hash.select_keys { |k| k == 'b' || k == 'd' }

      expect(trimmed_hash).not_to eq(hash)
      expect(trimmed_hash.keys).to contain_exactly('b', 'd')
      expect(trimmed_hash['d']).to eq('e' => 4)
    end
  end

  describe '#reject_keys' do
    it 'fails as expected' do
      expect{ hash.reject_keys(['a'], &:nil?) }.to raise_exception(ArgumentError)
      expect{ hash.reject_keys }.to raise_exception(ArgumentError)
    end

    it 'works as expected' do
      trimmed_hash = hash - %w(a b z)

      expect(trimmed_hash).not_to eq(hash)
      expect(trimmed_hash.keys).to contain_exactly(:c, 'd')
      expect(trimmed_hash['d']).to eq('e' => 4)
    end

    it 'works as expected with a Regexp' do
      trimmed_hash = hash - /a|c/

      expect(trimmed_hash).not_to eq(hash)
      expect(trimmed_hash.keys).to contain_exactly('b', 'd')
      expect(trimmed_hash['d']).to eq('e' => 4)
    end

    it 'works as expected with a block' do
      trimmed_hash = hash.reject_keys { |k| k == 'b' || k == 'd' }

      expect(trimmed_hash).not_to eq(hash)
      expect(trimmed_hash.keys).to contain_exactly('a', :c)
      expect(trimmed_hash['d']).to be_nil
    end
  end

  describe '#slice' do
    it 'works as expected' do
      trimmed_hash = hash.slice('a', 'b', 'z')

      expect(trimmed_hash).not_to eq(hash)
      expect(trimmed_hash.keys).to contain_exactly('a', 'b')
      expect(trimmed_hash['d']).to be_nil
    end
  end

  describe '#slice!' do
    it 'works as expected' do
      keys_before = hash.keys

      hash.slice!('a', 'b', 'z')

      expect(keys_before.size).not_to eq(hash.keys.size)
      expect(hash.keys).to contain_exactly('a', 'b')
      expect(hash['d']).to be_nil
    end
  end
end
