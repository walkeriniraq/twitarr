require 'securerandom'

class Message < BaseModel
  include HashInitialize

  attr_accessor :message, :username, :post_time, :post_id

  def initialize(hash = {})
    super(hash)
    # convert this back from an integer
    self.post_time = Time.at(self.post_time) unless self.post_time.is_a? Time
  end

  def self.new_post(message, username)
    self.new(message: message, username: username, post_time: Time.now, post_id: SecureRandom.uuid)
  end

  def to_json(params = {})
    { message: message, username: username, post_time: post_time.to_i, post_id: post_id }.to_json params
  end

end