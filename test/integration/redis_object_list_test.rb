require_relative '../test_helper'

class RedisObjectListTest < BaseTestCase
  subject { RedisObjectList }

  before do
    list = redis.list 'ObjectListTest'
    list.clear
  end

  it 'can add objects' do
    model = ObjectStoreTestModel.new foo: 'one', bar: 'two', baz: 'three'
    list = redis.list 'ObjectListTest'
    object_list = subject.new list, ObjectStoreTestModel
    object_list.unshift model
    list.first.must_be_instance_of String
    list.first.must_equal '{"foo":"one","bar":"two","baz":"three"}'
  end

  it 'can get objects' do
    model = ObjectStoreTestModel.new foo: 'one', bar: 'two', baz: 'three'
    list = redis.list 'ObjectListTest'
    object_list = subject.new list, ObjectStoreTestModel
    object_list.unshift model
    test = object_list.get(0)
    test.first.must_be_instance_of ObjectStoreTestModel
    test.first.foo.must_equal 'one'
    test.first.bar.must_equal 'two'
    test.first.baz.must_equal 'three'
  end

  it 'can get multiple objects' do
    list = redis.list 'ObjectListTest'
    object_list = subject.new list, ObjectStoreTestModel
    3.times do
      model = ObjectStoreTestModel.new foo: 'one', bar: 'two', baz: 'three'
      object_list.unshift model
    end
    test = object_list.get(0, 3)
    test.count.must_equal 3
    test.each { |x| x.must_be_instance_of ObjectStoreTestModel }
  end

end