# frozen_string_literal: true

FactoryBot.define do
  factory :processed_event do
    sequence(:event_id) { |n| "evt_#{n}" }
    processed_at { Time.current }
  end
end

