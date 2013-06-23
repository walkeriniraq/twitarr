require 'securerandom'

class Message
  include HashInitialize

  attr_accessor :message, :username, :post_time, :post_id

  def self.new_post(message, username)
    Message.new(message: message, username: username, post_time: Time.now, post_id: SecureRandom.uuid)
  end

  def to_json
    { message: message, username: username, post_time: post_time, post_id: post_id }.to_json
  end
end