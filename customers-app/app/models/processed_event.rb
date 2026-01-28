# ProcessedEvent stores event ids to ensure idempotent processing.
# Enforces uniqueness by event_id.
class ProcessedEvent < ApplicationRecord
  validates :event_id, presence: true, uniqueness: true
  validates :processed_at, presence: true
end
