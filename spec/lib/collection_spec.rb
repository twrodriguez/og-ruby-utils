require 'spec_helper'
require_relative 'common_collection_examples'

RSpec.describe OpenGov::Util::Collection, type: :library do
  let(:hashes) do
    [
      { a: 1, b: 2, c: 9 },
      { a: 2, b: 3, c: 8 },
      { a: 3, b: 4, c: 7 },
      { a: 4, b: nil, c: 6 },
      { a: 5, c: 5 }
    ]
  end

  describe '#initialize' do
    it 'can initialize from array-like objects' do
      collection = OpenGov::Util::Collection.new
      expect(collection).to be_empty
    end

    it 'can initialize from array-like objects' do
      collection = OpenGov::Util::Collection.new(1..5)
      expect(collection.size).to eq(5)
    end

    it 'can initialize from array-like objects' do
      collection = OpenGov::Util::Collection.new(hashes)
      expect(collection).to contain_exactly(*hashes)
    end

    it 'can\'t initialize from non-enumerable types' do
      expect { OpenGov::Util::Collection.new(1) }.to raise_exception(TypeError)
    end

    it 'can\'t initialize from explicitly passed nil' do
      expect { OpenGov::Util::Collection.new(nil) }.to raise_exception(TypeError)
    end
  end

  describe '#lazy' do
    it 'returns a LazyCollectionEnumerator' do
      expect(OpenGov::Util::Collection.new.lazy.class.ancestors).to include(::Enumerator::Lazy)
    end

    it 'can initialize with an infinite range' do
      collection = OpenGov::Util::Collection.new(1..Float::INFINITY).lazy
      expect(collection.first(5)).to contain_exactly(*1..5)
    end
  end

  #
  # Standard Methods
  #
  context 'immediate methods' do
    subject { OpenGov::Util::Collection.new(hashes) }
    it_behaves_like 'collection' # Using "hashes"
  end

  #
  # Lazy
  #
  context 'lazy methods' do
    subject { OpenGov::Util::Collection.new(hashes).lazy }
    it_behaves_like 'collection' # Using "hashes"
  end
end
