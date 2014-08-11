require 'bcrypt'

class User
  include Mongoid::Document

  USERNAME_REGEX = /^[\w&-]{3,}$/
  DISPLAY_NAME_REGEX = /^[\w\. &-]{3,40}$/

  field :un, as: :username, type: String
  field :pw, as: :password, type: String
  field :ia, as: :is_admin, type: Boolean
  field :st, as: :status, type: String
  field :em, as: :email, type: String
  field :dn, as: :display_name, type: String
  field :ll, as: :last_login, type: DateTime
  field :sq, as: :security_question, type: String
  field :sa, as: :security_answer, type: String

  validate :valid_username?
  validate :valid_display_name?
  validates :email, format: { with: /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i, message: 'address is not valid.'}
  validates :security_question, :security_answer, presence: true

  def self.valid_username?(username)
    return false unless username
    !username.match(USERNAME_REGEX).nil?
  end

  def valid_username?
    unless User.valid_username? (username)
      errors.add(:username, 'must be three or more characters and only include letters, numbers, underscore, dash, and ampersand')
    end
  end

  def self.valid_display_name?(name)
    return true unless name
    !name.match(DISPLAY_NAME_REGEX).nil?
  end

  def valid_display_name?
    unless User.valid_display_name? (display_name)
      errors.add(:display_name, 'must be three or more characters and cannot include any of ~!@#$%^*()+=<>{}[]\\|;:/?')
    end
  end

  def empty_password?
    password.nil? || password.empty?
  end

  def set_password(pass)
    self.password = BCrypt::Password.create pass
  end

  def correct_password(pass)
    BCrypt::Password.new(password) == pass
  end

  def update_last_login
    self.last_login = Time.now.to_f
    self
  end

  def username=(val)
    super val.andand.downcase
  end

  def security_answer=(val)
    super val.andand.downcase.andand.strip
  end

  def security_question=(val)
    super val.andand.strip
  end

  def display_name=(val)
    super val.andand.strip
  end

end