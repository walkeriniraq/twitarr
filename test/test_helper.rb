ENV['RAILS_ENV'] = 'test'

require File.expand_path('../../config/environment', __FILE__)

require 'rails/test_help'
require 'mocha/setup'

Turn.config do |c|
  c.format = :outline
end

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #fixtures :all

  # Add more helper methods to be used by all tests here...
end
