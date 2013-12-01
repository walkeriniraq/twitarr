require 'bcrypt'

class User < BaseModel

  USERNAME_REGEX = /^[\w&-]{5,}$/

  attr :username, :password, :is_admin, :status, :email

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

end
