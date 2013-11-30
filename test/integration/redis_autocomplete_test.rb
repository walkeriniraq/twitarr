require_relative '../test_helper'

class RedisAutocompleteTest < BaseTestCase
  subject { RedisAutocomplete }

  before do
    list = redis.sorted_set 'RedisAutocompleteTest'
    list.clear
  end

  it 'scores "aa" higher than "a"' do
    subject.calculate_score('aa').must_be :>, subject.calculate_score('a')
  end

  it 'scores "b" higher than "a"' do
    subject.calculate_score('b').must_be :>, subject.calculate_score('a')
  end

  it 'scores "A" same as "a"' do
    subject.calculate_score('A').must_equal subject.calculate_score('a')
  end

  it 'scores "z" higher than "0"' do
    subject.calculate_score('z').must_be :<, subject.calculate_score('0')
  end

  it 'scores "baa" higher than "a99"' do
    subject.calculate_score('baa').must_be :>, subject.calculate_score('a99')
  end

  it 'stops scoring at space' do
    subject.calculate_score('foo').must_equal subject.calculate_score('foo bar')
  end

  it 'stops scoring at period' do
    subject.calculate_score('foo').must_equal subject.calculate_score('foo.bar')
  end

  it 'stops scoring at comma' do
    subject.calculate_score('foo').must_equal subject.calculate_score('foo,bar')
  end

  it 'removes whitespace' do
    subject.calculate_score('foo').must_equal subject.calculate_score(' foo ')
  end

  it 'removes at signs' do
    subject.calculate_score('foo').must_equal subject.calculate_score('@foo')
  end

  it 'calculates the next score correctly' do
    subject.calculate_next_score('foobar').must_be :>, subject.calculate_score('foobar')
    subject.calculate_next_score('foo').must_be :>, subject.calculate_score('foo')
  end

  it 'calculates the next score as the next value for long strings' do
    subject.calculate_next_score('foobar').must_equal subject.calculate_score('foobas')
  end

  it 'calculates the next score as the next value' do
    subject.calculate_next_score('foo').must_equal subject.calculate_score('fop')
  end

  it 'calculates the next score correctly when last char is a z' do
    subject.calculate_next_score('foobzz').must_be :>, subject.calculate_score('foobzz')
  end

  it 'calculates the next score correctly when string is long' do
    subject.calculate_next_score('foobarbaz').must_be :>, subject.calculate_score('foobarbaz')
  end

  it 'stores the value in the autocomplete' do
    set = redis.sorted_set 'RedisAutocompleteTest'
    auto = subject.new set
    auto.add 'anna', 'anna', 'name'
    auto.query('an').must_include 'anna'
  end

  it 'stores the key with different unique values' do
    set = redis.sorted_set 'RedisAutocompleteTest'
    auto = subject.new set
    auto.add 'chellie', 'chellie', 'name'
    auto.add 'michelle', 'chellie', 'first_name'
    auto.query('chel').must_include 'chellie'
    auto.query('mich').must_include 'chellie'
  end

end
