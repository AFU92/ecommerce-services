require 'rails_helper'

RSpec.describe Customers::OrderEventBuilder do
  describe '.build' do
    it 'extracts event_id and nested customer_id' do
      payload = { 'event_id' => 'e1', 'order' => { 'customer_id' => 5 } }

      built = described_class.build(payload)

      expect(built).to eq(event_id: 'e1', customer_id: 5)
    end

    it 'falls back to top-level customer_id' do
      payload = { 'event_id' => 'e2', 'customer_id' => 7 }

      built = described_class.build(payload)

      expect(built[:event_id]).to eq('e2')
      expect(built[:customer_id]).to eq(7)
    end

    it 'raises KeyError when event_id is missing' do
      expect { described_class.build({}) }.to raise_error(KeyError)
    end
  end
end

