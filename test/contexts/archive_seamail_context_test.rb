require_relative '../test_helper'

class ArchiveSeamailContextTest < ActiveSupport::TestCase
  subject { ArchiveSeamailContext }
  let(:attributes) { %w(seamail username inbox_index archive_index) }

  include AttributesTest

  let(:seamail) { Seamail.new(seamail_id: '1234', sent_time: Time.now.to_f) }

  it 'removes the id from the inbox_index' do
    inbox = Set.new(['1234'])
    context = subject.new seamail: seamail,
                          username: 'foo',
                          inbox_index: inbox,
                          archive_index: {}
    context.call
    inbox.wont_include '1234'
  end

  it 'adds the id to the inbox_index' do
    archive = {}
    context = subject.new seamail: seamail,
                          username: 'foo',
                          inbox_index: Set.new(['1234']),
                          archive_index: archive
    context.call
    archive.keys.must_include seamail.seamail_id
  end

  it 'indexes the archived seamail correctly' do
    archive = {}
    context = subject.new seamail: seamail,
                          username: 'foo',
                          inbox_index: Set.new(['1234']),
                          archive_index: archive
    context.call
    archive.values.must_include seamail.sent_time
  end
end