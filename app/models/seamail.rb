class Seamail
  include Mongoid::Document

  field :sj, as: :subject, type: String
  field :us, as: :usernames, type: Array
  field :rd, as: :unread_users, type: Array
  embeds_many :messages, class_name: 'SeamailMessage', store_as: :sm, order: :timestamp.desc, validate: false

  validates :subject, presence: true
  validate :validate_users
  validate :validate_messages

  index usernames: 1
  index unread_users: 1
  index({:subject => 'text', :'sm.tx' => 'text'})

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
    super usernames.map { |x| User.format_username x }
  end

  def subject=(subject)
    super subject.andand.strip
  end

  def last_message
    messages.first.timestamp
  end

  def seamail_count
    messages.size
  end

  def mark_as_read(username)
    pull(:unread_users => username)
  end

  def reset_read(author)
    # noinspection RubyUnusedLocalVariable,RubyLocalVariableNamingConvention
    ur = usernames - [author]
    unread_users.clear
    unread_users.push *ur
    save!
  end

  def self.create_new_seamail(author, to_users, subject, first_message_text)
    to_users ||= []
    to_users << author
    seamail = Seamail.new(usernames: to_users, subject: subject, unread_users: to_users)
    seamail.messages << SeamailMessage.new(author: author, text: first_message_text, timestamp: Time.now)
    if seamail.valid?
      seamail.save
    end
    seamail
  end

  def add_message(author, text)
    reset_read author
    messages.create author: author, text: text, timestamp: Time.now
  end


end