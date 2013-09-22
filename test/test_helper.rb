ENV['RAILS_ENV'] = 'test'

require File.expand_path('../../config/environment', __FILE__)

require 'rails/test_help'
require 'mocha/setup'

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...
end

module AttributesTest
  def test_attributes_start_blank
    attributes.each do |attr|
      subject.new.send(attr).must_be_nil
    end
  end

  def test_constructor_attributes
    attributes.each do |attr|
      instance = subject.new attr => 'foo'
      instance.send(attr).must_equal 'foo'
    end
  end

  def test_send_attributes
    attributes.each do |attr|
      instance = subject.new
      instance.send(attr, 'bar')
      instance.send(attr).must_equal 'bar'
    end
  end
end

module UpdateTest
  def test_update_attributes
    attributes.each do |attr|
      instance = subject.new
      instance.send(:update, attr => 'baz')
      instance.send(attr).must_equal 'baz'
    end
  end
end

module DelegatorTest
  def test_delegate_to_object
    obj = OpenStruct.new thing: 'foo', other_thing: 'bar'
    role = subject.new(obj)
    role.thing.must_equal 'foo'
    role.other_thing.must_equal 'bar'
  end
end