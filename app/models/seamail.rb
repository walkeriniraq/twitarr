class Seamail
  include Mongoid::Document

  field :sj, as: :subject, type: String
  field :lm, as: :last_message, type: Time

  has_and_belongs_to_many :users
  has_many :seamail_messages, order: :timestamp.desc, validate: false

  validates :subject, presence: true
  validate :at_least_two_users?

  def at_least_two_users?
    errors[:base] << 'Must send email to another user of Twitarr' unless users.count > 1
  end

  def self.create_new_seamail(author, to_users, subject, first_message_text)
    seamail = Seamail.new(users: (to_users << author), subject: subject)
    message = seamail.seamail_messages.new(author: author.username, text: first_message_text, timestamp: Time.now)
    seamail.last_message = message.timestamp
    if seamail.valid?
      message.save
      seamail.save
    end
    seamail
  end

end