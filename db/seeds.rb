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
unless User.exist? 'steve'
  puts 'Creating user steve'
  user = User.new username: 'steve', display_name: 'steve',
                  is_admin: false, status: UserController::ACTIVE_STATUS, email: 'james@james.com',
                  security_question: 'none', security_answer: 'none'
  user.set_password 'steve'
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

def add_photo(url, localfilename, uploader, upload_date)

  photo_basename = File.basename localfilename
  return if PhotoMetadata.find_by ofn:photo_basename
  puts "Using photo #{url} => #{photo_basename}"
  open(url, 'rb') { |remote|
    open(localfilename, 'wb') { |local|
      local.write(remote.read)
    }
  }
  local_file = ActionDispatch::Http::UploadedFile.new(:tempfile => File.new(localfilename),
                                                     :filename => photo_basename)
  res = PhotoStore.instance.upload local_file, uploader
  photo_md = PhotoMetadata.find_by id: res[:photo]
  photo_md.upload_time = upload_date
  photo_md.save!
  photo_md
end
Mongoid.raise_not_found_error = false
Dir.mktmpdir do |dir|
  add_photo 'http://lorempixel.com/1900/1200/cats/5/', File.join(dir, 'cute_cat.jpg'), 'james', DateTime.civil(2014, 10, 13, 14, 30)
  add_photo 'http://lorempixel.com/1900/1200/cats/2/', File.join(dir, 'mean_cat.jpg'), 'steven', DateTime.civil(2014, 10, 14, 12, 0)
  add_photo 'http://lorempixel.com/1900/1200/cats/8/', File.join(dir, 'tired_cat.jpg'), 'james', DateTime.civil(2014, 10, 14, 12, 5)
end