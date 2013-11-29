require_relative '../test_helper'

class ValidateUserListContextTest < ActiveSupport::TestCase
  subject { ValidateUserListContext }
  let(:attributes) { %w(list user_set) }

  include AttributesTest

  it 'takes a string and returns a list' do
    context = subject.new list: 'foo bar', user_set: Set.new(['foo', 'bar'])
    test = context.call
    test.must_equal %w(foo bar)
  end

  it 'removes commas from the list' do
    context = subject.new list: 'foo, bar', user_set: Set.new(['foo', 'bar'])
    test = context.call
    test.must_equal %w(foo bar)
  end

  it 'removes at signs from the list' do
    context = subject.new list: '@foo, @bar', user_set: Set.new(['foo', 'bar'])
    test = context.call
    test.must_equal %w(foo bar)
  end

  it 'removes semicolons from the list' do
    context = subject.new list: '@foo;@bar', user_set: Set.new(['foo', 'bar'])
    test = context.call
    test.must_equal %w(foo bar)
  end

  it 'leaves a space after a comma' do
    context = subject.new list: 'foo,bar', user_set: Set.new(['foo', 'bar'])
    test = context.call
    test.must_equal %w(foo bar)
  end

  it 'returns nil if the users are not in the set' do
    context = subject.new list: 'foo,bar', user_set: Set.new()
    test = context.call
    test.must_equal nil
  end

  it 'validation is empty if names are in the set' do
    context = subject.new list: 'foo,bar', user_set: Set.new(['foo', 'bar'])
    context.call
    context.validation.must_equal []
  end

  it 'validation contains the missing names' do
    context = subject.new list: 'foo,bar', user_set: Set.new()
    context.call
    context.validation.must_equal ['foo', 'bar']
  end

  it 'returns nil if some of the users are not in the set' do
    context = subject.new list: 'foo,bar', user_set: Set.new(['foo'])
    test = context.call
    test.must_equal nil
  end

  it 'validation contains the missing name' do
    context = subject.new list: 'foo,bar', user_set: Set.new(['foo'])
    context.call
    context.validation.must_equal ['bar']
  end

end