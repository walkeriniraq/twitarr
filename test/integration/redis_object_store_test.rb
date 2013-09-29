require 'test_helper'

class RedisObjectStoreTest < BaseTestCase
  subject { RedisObjectStore }

  class ObjectStoreTestModel < BaseModel
    attr :foo, :bar, :baz
  end

  it 'can store and get objects' do
    model = ObjectStoreTestModel.new foo: 'one', bar: 'two', baz: 'three'
    object_store = subject.new redis
    object_store.save model, 1
    test = object_store.get ObjectStoreTestModel, 1
    test.must_be_instance_of ObjectStoreTestModel
    test.foo.must_equal 'one'
    test.bar.must_equal 'two'
    test.baz.must_equal 'three'
  end

  it 'can get a list of objects' do
    model = ObjectStoreTestModel.new foo: 'one', bar: 'two', baz: 'three'
    object_store = subject.new redis
    object_store.save model, 1
    object_store.save model, 2
    test = object_store.get ObjectStoreTestModel, [1, 2]
    test.must_be_instance_of Array
    test.count.must_equal 2
  end

  it 'returns nil if the object does not exist' do
    object_store = subject.new redis
    test = object_store.get ObjectStoreTestModel, 'thing that does not exist'
    test.must_be_nil
  end

  it 'returns empty array if an empty array passed in' do
    object_store = subject.new redis
    test = object_store.get ObjectStoreTestModel, []
    test.must_be_empty
  end

  it 'returns nil if nil passed in' do
    object_store = subject.new redis
    test = object_store.get ObjectStoreTestModel, nil
    test.must_be_nil
  end

  it 'removes missing objects from return array' do
    model = ObjectStoreTestModel.new foo: 'one', bar: 'two', baz: 'three'
    object_store = subject.new redis
    object_store.save model, 1
    object_store.save model, 2
    test = object_store.get ObjectStoreTestModel, [1, 2, 3]
    test.must_be_instance_of Array
    test.count.must_equal 2
  end

  it 'can delete objects' do
    model = ObjectStoreTestModel.new foo: 'one', bar: 'two', baz: 'three'
    object_store = subject.new redis
    object_store.save model, 1
    object_store.save model, 2
    test = object_store.get ObjectStoreTestModel, [1, 2]
    test.must_be_instance_of Array
    test.count.must_equal 2
    object_store.delete ObjectStoreTestModel, 1
    object_store.delete ObjectStoreTestModel, 2
    test = object_store.get ObjectStoreTestModel, [1, 2]
    test.must_be_instance_of Array
    test.count.must_equal 0
  end

end
