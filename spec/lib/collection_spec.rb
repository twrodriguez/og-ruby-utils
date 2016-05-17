require 'spec_helper'

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
  end

  describe '#where' do
    it 'returns a different collection' do
      collection = OpenGov::Util::Collection.new(hashes)
      collection_2 = collection.where a: 3

      expect(collection.size).to eq(hashes.size)
      expect(collection).not_to eq(collection_2)
    end

    it 'filters to the correct conditions' do
      collection = OpenGov::Util::Collection.new(hashes)
      collection_2 = collection.where a: 3
      collection_3 = collection.where a: 4, b: 9

      expect(collection_2.all? { |item| item[:a] == 3 }).to be true
      expect(collection_3).to be_empty
    end

    it 'it filters using nil correctly' do
      collection = OpenGov::Util::Collection.new(hashes)
      collection_2 = collection.where b: nil
      expect(collection_2.all? { |item| item[:b].nil? }).to be true
    end
  end

  describe '#where_not' do
    it 'returns a different collection' do
      collection = OpenGov::Util::Collection.new(hashes)
      collection_2 = collection.where_not a: 4

      expect(collection.size).to eq(hashes.size)
      expect(collection).not_to eq(collection_2)
    end

    it 'filters to the correct conditions' do
      collection = OpenGov::Util::Collection.new(hashes)
      collection_2 = collection.where_not a: 4
      collection_3 = collection.where_not a: 4, b: [2, 3, 4]

      expect(collection_2.all? { |item| item[:a] != 4 }).to be true
      expect(collection_3).to contain_exactly(a: 5, c: 5)
    end

    it 'it filters using nil correctly' do
      collection = OpenGov::Util::Collection.new(hashes)
      collection_2 = collection.where_not b: nil
      expect(collection_2.any? { |item| item[:b].nil? }).to be false
    end
  end

  describe '#pluck' do
    it 'returns a different collection' do
      collection = OpenGov::Util::Collection.new(hashes)
      collection_2 = collection.pluck :a

      expect(collection.size).to eq(hashes.size)
      expect(collection).not_to eq(collection_2)
    end

    it 'plucks with a single argument' do
      collection = OpenGov::Util::Collection.new(hashes)
      collection_2 = collection.pluck :a

      expect(collection.all? { |item| item.is_a? Hash }).to be true
      expect(collection_2.all? { |item| item.is_a? Hash }).to be false
      expect(collection_2).to contain_exactly(1, 2, 3, 4, 5)
    end

    it 'plucks with multiple arguments' do
      collection = OpenGov::Util::Collection.new(hashes)
      collection_2 = collection.pluck :a, :b

      expect(collection.all? { |item| item.is_a? Hash }).to be true
      expect(collection_2.any? { |item| item.is_a? Array }).to be true
    end
  end
end
