# Model spec covering Order validations.
require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'validations' do
    subject { build(:order) }

    it { should validate_presence_of(:customer_id) }
    it { should validate_presence_of(:product_name) }
    it { should validate_presence_of(:status) }
    it { should validate_numericality_of(:quantity).only_integer.is_greater_than(0) }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
  end
end
