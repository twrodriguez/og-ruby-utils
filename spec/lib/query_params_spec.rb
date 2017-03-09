# frozen_string_literal: true
require 'spec_helper'

RSpec.describe OpenGov::Util::QueryParams, type: :library do
  describe '.encode' do
    it 'encodes params that are symbols' do
      expect(OpenGov::Util::QueryParams.encode(api_key: 'akey')).to eq('?api_key=akey')
    end

    it 'encodes params that are strings' do
      expect(OpenGov::Util::QueryParams.encode('api_key' => 'akey')).to eq('?api_key=akey')
    end

    it 'encodes params that contain arrays' do
      expect(OpenGov::Util::QueryParams.encode('hello' => %w(yolo1 yolo2))).to eq('?hello%5B%5D=yolo1&hello%5B%5D=yolo2')
    end

    it 'encodes params that contain sets' do
      expect(OpenGov::Util::QueryParams.encode('hello' => Set.new(%w(yolo1 yolo2)))).to eq('?hello%5B%5D=yolo1&hello%5B%5D=yolo2')
    end

    it 'encodes params that contain collections' do
      expect(OpenGov::Util::QueryParams.encode('hello' => OpenGov::Util::Collection.new(%w(yolo1 yolo2)))).to eq('?hello%5B%5D=yolo1&hello%5B%5D=yolo2')
    end

    it 'encodes params that contain enumerators' do
      expect(OpenGov::Util::QueryParams.encode('hello' => %w(yolo1 yolo2).each)).to eq('?hello%5B%5D=yolo1&hello%5B%5D=yolo2')
    end

    it 'encodes multiple params' do
      encoded_params = OpenGov::Util::QueryParams.encode(
        'hello1' => %w(yolo1 yolo11),
        :hello2 => 'yolo2',
        'hello3' => 'yolo3'
      )
      expect(encoded_params[1..-1].split('&')).to contain_exactly('hello2=yolo2', 'hello3=yolo3', 'hello1%5B%5D=yolo1', 'hello1%5B%5D=yolo11')
    end
  end

  describe '.decode' do
    it 'decodes a query string' do
      expect(OpenGov::Util::QueryParams.decode('?api_key=akey')).to eq('api_key' => 'akey')
    end

    it 'decodes an array val' do
      expect(OpenGov::Util::QueryParams.decode('?hello%5B%5D=yolo1&hello%5B%5D=yolo2')).to eq('hello' => %w(yolo1 yolo2))
    end

    it 'decodes into an existing custom hash' do
      my_hash = {}
      my_hash_id = my_hash.object_id
      expect(OpenGov::Util::QueryParams.decode('?api_key=akey', my_hash).object_id).to eq(my_hash_id)
    end
  end
end
