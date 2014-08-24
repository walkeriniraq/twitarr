class Seamail
  include Mongoid::Document

  field :sj, as: :subject, type: String
  field :us, as: :usernames, type: Array
  embeds_many :messages, class_name: 'SeamailMessage', store_as: :sm, order: :timestamp.desc, validate: false

  validates :subject, presence: true
  validate :validate_users
  validate :validate_messages

  def validate_users
    errors[:base] << 'Must send email to another user of Twitarr' unless usernames.count > 1
    usernames.each do |username|
      unless User.exist? username
        errors[:base] << "#{username} is not a valid username"
      end
    end
  end

  def validate_messages
    errors[:base] << 'Must include a message' if messages.size < 1
    messages.each do |message|
      unless message.valid?
        message.errors.full_messages.each { |x| errors[:base] << x }
      end
    end
  end

  def usernames=(usernames)
    self[:usernames] = usernames.map { |x| User.format_username x }
  end

  def subject=(subject)
    self[:subject] = subject.andand.strip
  end

  def last_message
    messages.first.timestamp
  end

  def seamail_count
    messages.size
  end

  def self.create_new_seamail(author, to_users, subject, first_message_text)
    to_users ||= []
    to_users << author
    seamail = Seamail.new(usernames: to_users, subject: subject)
    seamail.messages << SeamailMessage.new(author: author, text: first_message_text, timestamp: Time.now)
    if seamail.valid?
      seamail.save
    end
    seamail
  end

  def add_message(author, text)
    messages.create author: author, text: text, timestamp: Time.now
  end

end