require 'test_helper'

class BaseModelTest < ActiveSupport::TestCase

  def attributes_start_blank_test(attributes)
    attributes.each do |x|
      subject.new.send(x).must_be_nil
    end
  end

  def attributes_read_and_write_test(attributes)
    attributes.each do |attr|
      subject.fattrs.must_include attr
      instance = subject.new attr => 'foo'
      instance.send(attr).must_equal 'foo'
      instance.send(attr, 'bar')
      instance.send(attr).must_equal 'bar'
    end
  end

end
