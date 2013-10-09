require 'bcrypt'

class User < BaseModel

  attr :username, :password, :is_admin, :status, :email

  def self.valid_username?(username)
    [':', ' ', '#', '%', '@'].all? { |x| !username.include? x }
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
