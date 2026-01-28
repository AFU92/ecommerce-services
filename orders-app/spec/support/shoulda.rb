# frozen_string_literal: true

# Shoulda Matchers + FactoryBot helpers
RSpec.configure do |config|
  # Use short FactoryBot syntax: create(:order)
  config.include FactoryBot::Syntax::Methods
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

