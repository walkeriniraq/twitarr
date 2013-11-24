require 'test_helper'

class CreateSeamailContextTest < ActiveSupport::TestCase
  subject { CreateSeamailContext }
  let(:attributes) { %w(seamail from_user_sent_index inbox_index_factory seamail_store) }

  include AttributesTest

  class FakeSeamailStore
    attr :store

    def initialize
      @store = {}
    end

    def save(post, id)
      @store[id] = post
    end
  end

  let(:seamail) { Seamail.new(from: 'foo', to: 'bar') }
  let(:seamail_store) { FakeSeamailStore.new }
  let(:inbox_index) { {} }

  it 'sets the time on the seamail' do
    context = subject.new seamail: seamail,
                          from_user_sent_index: {},
                          inbox_index_factory: lambda { |_| inbox_index },
                          seamail_store: seamail_store
    context.call
    seamail.sent_time.must_be_close_to DateTime.now.to_f, 1
  end

  it 'sets the id on the seamail' do
    context = subject.new seamail: seamail,
                          from_user_sent_index: {},
                          inbox_index_factory: lambda { |_| inbox_index },
                          seamail_store: seamail_store
    context.call
    seamail.seamail_id.wont_be_nil
  end

  it 'sets the sent_index for the sender' do
    context = subject.new seamail: seamail,
                          from_user_sent_index: sent_index = {},
                          inbox_index_factory: lambda { |_| inbox_index },
                          seamail_store: seamail_store
    context.call
    sent_index.keys.must_include seamail.seamail_id
    sent_index.values.must_include seamail.sent_time
  end

  it 'sets the inbox_index for a single user' do
    context = subject.new seamail: seamail,
                          from_user_sent_index: {},
                          inbox_index_factory: lambda { |_| inbox_index },
                          seamail_store: seamail_store
    context.call
    inbox_index.keys.must_include seamail.seamail_id
    inbox_index.values.must_include seamail.sent_time
  end

  it 'sets the inbox_index for an array of users' do
    inboxes = {}
    seamail = Seamail.new(from: 'foo', to: %w(steve dave))
    context = subject.new seamail: seamail,
                          from_user_sent_index: {},
                          inbox_index_factory: lambda { |name| inboxes[name] ||= {} },
                          seamail_store: seamail_store
    context.call
    seamail_store.store[seamail.seamail_id].must_equal seamail
    inboxes.keys.must_include 'steve'
    inboxes.keys.must_include 'dave'
    %w(steve dave).each do |name|
      inboxes[name].keys.must_include seamail.seamail_id
      inboxes[name].values.must_include seamail.sent_time
    end
  end

  it 'should return the seamail object' do
    context = subject.new seamail: seamail,
                          from_user_sent_index: {},
                          inbox_index_factory: lambda { |_| inbox_index },
                          seamail_store: seamail_store
    test = context.call
    test.must_equal seamail
  end

end
