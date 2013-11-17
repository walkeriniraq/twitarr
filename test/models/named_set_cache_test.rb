require 'test_helper'

class NamedSetCacheTest < ActiveSupport::TestCase
  subject { NamedSetCache }

  def test_get_gets_set_from_factory
    called = false
    test = subject.new(Proc.new do |name|
      called = true
      'foo'
    end)
    test['steve'].must_equal 'foo'
    called.must_equal true
  end

  def test_get_caches_result
    called = 0
    test = subject.new(Proc.new do |name|
      called += 1
    end)
    test['steve']
    test['steve']
    called.must_equal 1
  end

end