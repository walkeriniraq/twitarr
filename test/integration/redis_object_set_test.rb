require_relative '../test_helper'

class RedisObjectSetTest < BaseTestCase
  subject { RedisObjectSet }

  before do
    list = redis.sorted_set 'ObjectSetTest'
    list.clear
  end

  it 'can add objects' do
    model = ObjectStoreTestModel.new foo: 'one', bar: 'two', baz: 'three'
    list = redis.sorted_set 'ObjectSetTest'
    set = subject.new list, ObjectStoreTestModel
    set.save model, 543
    list['{"foo":"one","bar":"two","baz":"three"}'].must_equal 543
  end

  it 'gets object' do
    model = ObjectStoreTestModel.new foo: 'one', bar: 'two', baz: 'three'
    list = redis.sorted_set 'ObjectSetTest'
    set = subject.new list, ObjectStoreTestModel
    set.save model, 432
    set.get(400, 500).count.must_equal 1
    set.get(400, 500).first.foo.must_equal 'one'
  end

  it 'does not limit results by default' do
    model = ObjectStoreTestModel.new bar: 'two', baz: 'three'
    list = redis.sorted_set 'ObjectSetTest'
    set = subject.new list, ObjectStoreTestModel
    10.times do |x|
      model.foo = x
      set.save model, 120 + x
    end
    test = set.get(100, 200)
    test.count.must_equal 10
  end

  it 'does not limit results' do
    model = ObjectStoreTestModel.new bar: 'two', baz: 'three'
    list = redis.sorted_set 'ObjectSetTest'
    set = subject.new list, ObjectStoreTestModel
    10.times do |x|
      model.foo = x
      set.save model, 120 + x
    end
    test = set.get(100, 200, 4)
    test.count.must_equal 4
  end

  it 'gets results in reverse order' do
    model = ObjectStoreTestModel.new bar: 'two', baz: 'three'
    list = redis.sorted_set 'ObjectSetTest'
    set = subject.new list, ObjectStoreTestModel
    10.times do |x|
      model.foo = x
      set.save model, 120 + x
    end
    test = set.get(125, 122, 4)
    test.count.must_equal 4
    test.first.foo.must_equal 5
    test.last.foo.must_equal 2
  end

end