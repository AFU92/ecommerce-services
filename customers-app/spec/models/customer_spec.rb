require 'rails_helper'

RSpec.describe Customer, type: :model do
  describe 'validations' do
    subject { build(:customer) }

    it { should validate_presence_of(:customer_name) }
    it { should validate_presence_of(:address) }
    it { should validate_numericality_of(:orders_count).only_integer.is_greater_than_or_equal_to(0) }
  end
end
