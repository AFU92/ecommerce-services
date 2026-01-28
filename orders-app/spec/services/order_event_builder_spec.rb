require 'rails_helper'

RSpec.describe OrderEventBuilder do
  describe '.build' do
    it 'builds payload with fixed event_id and formatted fields' do
      t = Time.utc(2023, 1, 1, 10, 0, 0)
      order = create(:order, price: 12.34, created_at: t)

      payload = described_class.build(order, event_id: 'evt-123')

      expect(payload[:event_id]).to eq('evt-123')
      expect(payload[:order][:id]).to eq(order.id)
      expect(payload[:order][:customer_id]).to eq(order.customer_id)
      expect(payload[:order][:product_name]).to eq(order.product_name)
      expect(payload[:order][:quantity]).to eq(order.quantity)
      expect(payload[:order][:price]).to eq('12.34')
      expect(payload[:order][:status]).to eq(order.status)
      expect(payload[:order][:created_at]).to eq(t.iso8601)
    end
  end
end
