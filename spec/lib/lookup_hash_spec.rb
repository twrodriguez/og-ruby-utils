# frozen_string_literal: true
require 'spec_helper'

RSpec.describe OpenGov::Util::LookupHash, type: :library do
  let(:hash) do
    {
      'a' => 1,
      'b' => 2,
      'c' => 3
    }
  end

  describe 'to_proc' do
    it 'can be passed as a block' do
      lookup_hash = OpenGov::Util::LookupHash.new.merge(hash)
      expect(('a'..'d').map(&lookup_hash)).to eq([1, 2, 3, nil])
      lookup_hash['d'] = 4
      expect(('a'..'d').map(&lookup_hash)).to eq([1, 2, 3, 4])
    end
  end
end
