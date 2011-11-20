ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
Dir.glob(File.expand_path('../factories', __FILE__) + '/**/*.rb').each {|rb| require rb }
require 'pp'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting

  # Add more helper methods to be used by all tests here...
  include Sorcery::TestHelpers::Rails
end
