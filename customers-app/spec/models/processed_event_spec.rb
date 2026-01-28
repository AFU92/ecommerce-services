require 'rails_helper'

RSpec.describe ProcessedEvent, type: :model do
  describe 'validations' do
    subject { create(:processed_event) }

    it { should validate_presence_of(:event_id) }
    it { should validate_presence_of(:processed_at) }
    it { should validate_uniqueness_of(:event_id) }
  end
end
