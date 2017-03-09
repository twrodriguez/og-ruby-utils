# frozen_string_literal: true
require 'spec_helper'

RSpec.describe OpenGov::Util::Thread, type: :library do
  THREAD = OpenGov::Util::Thread

  describe 'lineage' do
    it 'can walk up the parents' do
      THREAD.current[:foo] = 0

      THREAD.new do
        THREAD.current[:foo] = 1

        THREAD.new do
          THREAD.current[:foo] = 2

          THREAD.new do
            THREAD.current[:foo] = 3

            expect(THREAD.current.lineage.map { |thr| thr[:foo] }).to eq([3, 2, 1, 0])
          end
        end
      end
    end
  end
end
