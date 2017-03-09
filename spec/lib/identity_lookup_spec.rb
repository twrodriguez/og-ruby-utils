# frozen_string_literal: true
require 'spec_helper'

RSpec.describe OpenGov::Util::IdentityLookup, type: :library do
  let(:hash) do
    {
      'a' => 1,
      'b' => 2,
      'c' => 3
    }
  end

  describe 'to_proc' do
    it 'returns what was passed to it by default' do
      lookup_hash = OpenGov::Util::IdentityLookup.new
      expect(lookup_hash[1]).to eq(1)
      expect(lookup_hash['a']).to eq('a')
      expect(lookup_hash[[1, 2, 3]]).to eq([1, 2, 3])
    end

    it 'can be overridden' do
      lookup_hash = OpenGov::Util::IdentityLookup.new
      expect(lookup_hash[1]).to eq(1)
      lookup_hash[1] = 'foo'
      expect(lookup_hash[1]).to eq('foo')
    end

    it 'can be passed as a block' do
      lookup_hash = OpenGov::Util::IdentityLookup.new.merge(hash)
      expect(('a'..'e').map(&lookup_hash)).to eq([1, 2, 3, 'd', 'e'])
      lookup_hash['e'] = 5
      expect(('a'..'e').map(&lookup_hash)).to eq([1, 2, 3, 'd', 5])
    end
  end
end
