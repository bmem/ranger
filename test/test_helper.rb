ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all
  self.use_transactional_fixtures = true

  # Spend less time making passwords
  Devise.stretches = 1

  # Do less I/O when testing, so run faster.
  # Comment this line out if you need to examine log/test.log for details
  Rails.logger.level = 4

  def assert_valid(record)
    assert record.valid?, record.errors.full_messages.join('; ')
  end
  # Add more helper methods to be used by all tests here...
end

class ActionController::TestCase
  include Devise::TestHelpers
end
