require 'spec_helper'

RSpec.describe OpenGov::Util::NestedHash, type: :library do
  describe 'behavior' do
    it 'allows for arbitrary depth of hash sets' do
      nested_hash = OpenGov::Util::NestedHash.new
      nested_hash[:a][:b][:c][:d][:e][:f][:g] = 'fun!'
      expect(nested_hash).to eq(a: { b: { c: { d: { e: { f: { g: 'fun!' } } } } } })
    end
  end
end
