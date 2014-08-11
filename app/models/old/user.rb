# require 'bcrypt'
#
# class User < BaseModel
#   include ActiveModel::Validations
#   USERNAME_REGEX = /^[\w&-]{3,}$/
#   DISPLAY_NAME_REGEX = /^[\w\. &-]{3,40}$/
#
#   attr :username, :password, :is_admin, :status, :email, :display_name,
#        :last_login, :last_checked_posts, :security_question, :security_answer
#
#   validate :valid_username?
#   validate :valid_display_name?
#   validates :email, format: { with: /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i, message: 'address is not valid.'}
#   validates :security_question, :security_answer, presence: true
#
#   def self.valid_username?(username)
#     return false unless username
#     !username.match(USERNAME_REGEX).nil?
#   end
#
#   def self.valid_display_name?(name)
#     return true unless name
#     !name.match(DISPLAY_NAME_REGEX).nil?
#   end
#
#   def valid_username?
#     unless User.valid_username? (username)
#       errors.add(:username, 'must be three or more characters and only include letters, numbers, underscore, dash, and ampersand')
#     end
#   end
#
#   def valid_display_name?
#     unless User.valid_display_name? (display_name)
#       errors.add(:display_name, 'must be three or more characters and cannot include any of ~!@#$%^*()+=<>{}[]\\|;:/?')
#     end
#   end
#
#   def set_password(pass)
#     @password = BCrypt::Password.create pass
#   end
#
#   def correct_password(pass)
#     BCrypt::Password.new(password) == pass
#   end
#
#   def username=(val)
#     @username = val.andand.downcase
#   end
#
#   def empty_password
#     password.nil? || password.empty?
#   end
#
#   def update_last_login
#     @last_login = Time.now.to_f
#     self
#   end
#
#   def last_login_readable
#     return Time.at(@last_login) unless @last_login.nil?
#     @last_login
#   end
#
#   def update_last_checked_posts
#     @last_checked_posts = Time.now.to_f
#     self
#   end
#
#   def security_answer=(val)
#     @security_answer = val.andand.downcase.andand.strip
#   end
#
#   def security_question=(val)
#     @security_question = val.andand.strip
#   end
#
#   def display_name=(val)
#     @display_name = val.andand.strip
#   end
#
# end
