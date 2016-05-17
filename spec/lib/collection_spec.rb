require 'spec_helper'

RSpec.shared_examples 'collection' do
  describe '#where' do
    it 'returns a different subject' do
      collection_2 = subject.where a: 3

      expect(subject.size).to eq(hashes.size)
      expect(subject).not_to eq(collection_2)
    end

    it 'filters to the correct conditions' do
      collection_2 = subject.where a: 3
      collection_3 = subject.where a: 4, b: 9

      expect(collection_2.all? { |item| item[:a] == 3 }).to be true
      expect(collection_3.first).to be_nil
    end

    it 'it filters using nil correctly' do
      collection_2 = subject.where b: nil
      expect(collection_2.all? { |item| item[:b].nil? }).to be true
    end
  end

  describe '#where_not' do
    it 'returns a different subject' do
      collection_2 = subject.where_not a: 4

      expect(subject.size).to eq(hashes.size)
      expect(subject).not_to eq(collection_2)
    end

    it 'filters to the correct conditions' do
      collection_2 = subject.where_not a: 4
      collection_3 = subject.where_not a: 4, b: [2, 3, 4]

      expect(collection_2.all? { |item| item[:a] != 4 }).to be true
      expect(collection_3).to contain_exactly(a: 5, c: 5)
    end

    it 'it filters using nil correctly' do
      collection_2 = subject.where_not b: nil
      expect(collection_2.any? { |item| item[:b].nil? }).to be false
    end
  end

  describe '#pluck' do
    it 'returns a different subject' do
      collection_2 = subject.pluck :a

      expect(subject.size).to eq(hashes.size)
      expect(subject).not_to eq(collection_2)
    end

    it 'plucks with a single argument' do
      collection_2 = subject.pluck :a

      expect(subject.all? { |item| item.is_a? Hash }).to be true
      expect(collection_2.all? { |item| item.is_a? Hash }).to be false
      expect(collection_2).to contain_exactly(1, 2, 3, 4, 5)
    end

    it 'plucks with multiple arguments' do
      collection_2 = subject.pluck :a, :b

      expect(subject.all? { |item| item.is_a? Hash }).to be true
      expect(collection_2.any? { |item| item.is_a? Array }).to be true
    end
  end

  describe '#pluck_to_h' do
    it 'returns a different subject' do
      collection_2 = subject.pluck_to_h :a

      expect(subject.size).to eq(hashes.size)
      expect(subject).not_to eq(collection_2)
    end

    it 'plucks with a single argument' do
      collection_2 = subject.pluck_to_h :a

      expect(subject.all? { |item| item.is_a? Hash }).to be true
      expect(collection_2.all? { |item| item.is_a? Hash }).to be true
      expect(collection_2).to contain_exactly({a: 1}, {a: 2}, {a: 3}, {a: 4}, {a: 5})
    end

    it 'plucks with multiple arguments' do
      collection_2 = subject.pluck_to_h :a, :b

      expect(subject.all? { |item| item.is_a? Hash }).to be true
      expect(collection_2.all? { |item| item.is_a? Hash }).to be true
      expect(collection_2.all? { |item| item.key?(:a) && item.key?(:b) }).to be true
    end
  end
end

RSpec.describe OpenGov::Util::Collection, type: :library do
  let(:hashes) do
    [
      {a: 1, b: 2, c: 9},
      {a: 2, b: 3, c: 8},
      {a: 3, b: 4, c: 7},
      {a: 4, b: nil, c: 6},
      {a: 5, c: 5}
    ]
  end

  describe '#initialize' do
    it 'can initialize from array-like objects' do
      collection = OpenGov::Util::Collection.new()
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
      expect(OpenGov::Util::Collection.new().lazy.class.ancestors).to include(::Enumerator::Lazy)
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
    it_behaves_like 'collection'
  end

  #
  # Lazy
  #
  context 'lazy methods' do
    subject { OpenGov::Util::Collection.new(hashes).lazy }
    it_behaves_like 'collection'
  end
end
