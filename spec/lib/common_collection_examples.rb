RSpec.shared_examples 'collection' do # Assumes "hashes" is defined in a `let` variable
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

  describe '#pluck_slice' do
    it 'returns a different subject' do
      collection_2 = subject.pluck_slice :a

      expect(subject.size).to eq(hashes.size)
      expect(subject).not_to eq(collection_2)
    end

    it 'plucks with a single argument' do
      collection_2 = subject.pluck_slice :a

      expect(subject.all? { |item| item.is_a? Hash }).to be true
      expect(collection_2.all? { |item| item.is_a? Hash }).to be true
      expect(collection_2).to contain_exactly({a: 1}, {a: 2}, {a: 3}, {a: 4}, {a: 5})
    end

    it 'plucks with multiple arguments' do
      collection_2 = subject.pluck_slice :a, :b

      expect(subject.all? { |item| item.is_a? Hash }).to be true
      expect(collection_2.all? { |item| item.is_a? Hash }).to be true
      expect(collection_2.all? { |item| item.key?(:a) && item.key?(:b) }).to be true
    end
  end
end
