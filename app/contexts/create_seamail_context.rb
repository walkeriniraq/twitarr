class CreateSeamailContext
  include HashInitialize

  attr :seamail, :from_user_sent_index, :inbox_index_factory, :object_store

  def initialize(attrs = {})
    super
    @seamail = SeamailRole.new(@seamail)
    @from_user_sent_index = FromUserIndexRole.new(@from_user_sent_index)
  end

  def call
    seamail.seamail_id = SecureRandom.uuid
    seamail.sent_time = Time.now.to_f
    object_store.save(seamail, seamail.seamail_id)
    from_user_sent_index.add_seamail(seamail)
    seamail.to.each do |to_user|
      InboxIndexRole.new(inbox_index_factory.call(to_user)).add_seamail(seamail)
    end
  end

  class SeamailRole < SimpleDelegator
    # don't need any additional functionality at this time
  end

  module IndexSeamailTimeTrait
    def add_seamail(seamail)
      self[seamail.seamail_id] = seamail.sent_time
    end
  end

  class FromUserIndexRole < SimpleDelegator
    include IndexSeamailTimeTrait
  end

  class InboxIndexRole < SimpleDelegator
    include IndexSeamailTimeTrait
  end

end