require 'test_helper'

class SeamailTest < ActiveSupport::TestCase
  subject { Seamail }
  let(:attributes) { %w(seamail_id from subject text) }

  include AttributesTest
  include UpdateTest

  it 'lowercases the from name' do
    test = subject.new(from: 'FOO')
    test.from.must_equal 'foo'
  end

  it 'lowercases a single TO name' do
    test = subject.new(to: 'FOO')
    test.to.must_include 'foo'
  end

  it 'returns an array for a single TO name' do
    test = subject.new(to: 'foo')
    test.to.must_be_kind_of Enumerable
    test.to.must_include 'foo'
  end

  it 'lowercases multiple TO names' do
    test = subject.new(to: ['FOO', 'BAR'])
    test.to.must_include 'foo'
    test.to.must_include 'bar'
  end

  it 'starts sent_time as zero' do
    test = subject.new
    test.sent_time.must_equal 0.0
  end

  it 'constructs sent_time to a float' do
    test = subject.new sent_time: Time.now
    test.sent_time.must_be_kind_of Float
  end

  it 'converts set sent_time to a float' do
    test = subject.new
    test.sent_time = Time.now
    test.sent_time.must_be_kind_of Float
  end

end