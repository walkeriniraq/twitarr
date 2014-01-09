require 'bcrypt'

class User < BaseModel

  USERNAME_REGEX = /^[\w&-]{5,}$/

  attr :username, :password, :is_admin, :status, :email, :display_name, :last_login, :last_checked_posts

  def self.valid_username?(username)
    !username.match(USERNAME_REGEX).nil?
  end

  def set_password(pass)
    @password = BCrypt::Password.create pass
  end

  def correct_password(pass)
    BCrypt::Password.new(password) == pass
  end

  def username
    @username.andand.downcase
  end

  def empty_password
    password.nil? || password.empty?
  end

  def update_last_login
    @last_login = Time.now.to_f
    self
  end

  def last_login_readable
    return Time.at(@last_login) unless @last_login.nil?
    @last_login
  end

  def update_last_checked_posts
    @last_checked_posts = Time.now.to_f
    self
  end

end
