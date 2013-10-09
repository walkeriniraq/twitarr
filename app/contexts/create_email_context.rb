class CreateEmailContext
  include HashInitialize

  attr :email, :from_user_sent_index, :inbox_index_factory, :object_store

  def initialize(attrs = {})
    super
    @email = EmailRole.new(@email)
    @from_user_sent_index = FromUserIndexRole.new(@from_user_sent_index)
  end

  def call
    email.email_id = SecureRandom.uuid
    email.sent_time = Time.now.to_f
    object_store.save(email, email.email_id)
    from_user_sent_index.add_email(email)
    [*email.to].each do |to_user|
      InboxIndexRole.new(inbox_index_factory.call(to_user)).add_email(email)
    end
  end

  class EmailRole < SimpleDelegator
    # don't need any additional functionality at this time
  end

  module IndexEmailTimeTrait
    def add_email(email)
      self[email.email_id] = email.sent_time
    end
  end

  class FromUserIndexRole < SimpleDelegator
    include IndexEmailTimeTrait
  end

  class InboxIndexRole < SimpleDelegator
    include IndexEmailTimeTrait
  end

end