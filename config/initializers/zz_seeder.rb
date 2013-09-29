#TWITARR_INSTANCE.tap do |twitarr|
#  unless twitarr.user_exist? 'kvort'
#    twitarr.add_user(username: 'kvort', password: 'change_me', is_admin: true, status: User::STATUS_ACTIVE, email: 'kvort@rylath.net')
#  end
#end
#unless User.exist? 'kvort'
#  user = User.new username: 'kvort', is_admin: true, status: User::STATUS_ACTIVE, email: 'kvort@rylath.net'
#  user.set_password 'changeme'
#  user.save
#end
