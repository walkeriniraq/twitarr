ENV['RAILS_ENV'] = 'test'

require File.expand_path('../../config/environment', __FILE__)

require 'rails/test_help'
require 'mocha/setup'

require_relative 'traits/index_score_trait_tests'
require_relative 'traits/index_time_trait_tests'
require_relative 'traits/post_role_trait_tests'
require_relative 'traits/post_score_trait_tests'
require_relative 'traits/post_time_index_trait_tests'

class ObjectStoreTestModel < BaseModel
  attr :foo, :bar, :baz
end

class BaseTestCase < ActiveSupport::TestCase

  def redis
    #@redis ||= Redis.new(host: 'gremlin', db: 15)
    @redis ||= Redis.new(db: 15)
  end

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
      instance.send("#{attr}=", 'bar')
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