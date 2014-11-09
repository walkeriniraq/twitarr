puts "Using rails env #{Rails.env}"
unless User.exist? 'kvort'
  puts 'Creating user kvort'
  user = User.new username: 'kvort', display_name: 'kvort',
                  is_admin: true, status: UserController::ACTIVE_STATUS, email: 'kvort@rylath.net',
                  security_question: 'none', security_answer: 'none'
  user.set_password 'kvort'
  user.save
end
unless User.exist? 'james'
  puts 'Creating user james'
  user = User.new username: 'james', display_name: 'james',
                  is_admin: false, status: UserController::ACTIVE_STATUS, email: 'james@james.com',
                  security_question: 'none', security_answer: 'none'
  user.set_password 'james'
  user.save
end
unless User.exist? 'admin'
  puts 'Creating user admin'
  user = User.new username: 'admin', display_name: 'admin',
                  is_admin: true, status: UserController::ACTIVE_STATUS, email: 'admin@james.com',
                  security_question: 'none', security_answer: 'none'
  user.set_password 'admin'
  user.save
end
