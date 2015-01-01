@BASE_DATE = DateTime.now - 1.day

puts "Using rails env #{Rails.env}"
puts "Using a base date of #{@BASE_DATE}"

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

# noinspection RubyResolve
def add_photo(url, localfilename, uploader, upload_date)

  photo_basename = File.basename localfilename
  photo_md = PhotoMetadata.find_by ofn:photo_basename
  return photo_md if photo_md
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

def at_time(hr, min, params = {})
  dt = @BASE_DATE
  dt = dt - params[:offset] if params.has_key? :offset
  params.delete :offset
  params[:hour] = hr
  params[:min] = min
  dt.change params
end

# noinspection RubyResolve
Mongoid.raise_not_found_error = false
photos = []
Dir.mktmpdir do |dir|
  photos.push add_photo('http://lorempixel.com/1900/1200/cats/5/', File.join(dir, 'cute_cat.jpg'), 'james', at_time(14, 30, offset: -1.day))
  photos.push add_photo('http://lorempixel.com/1900/1200/cats/2/', File.join(dir, 'mean_cat.jpg'), 'steve', at_time(12, 0))
  photos.push add_photo('http://lorempixel.com/1900/1200/cats/8/', File.join(dir, 'tired_cat.jpg'), 'james', at_time(12, 5))
  photos.push add_photo('http://i.imgur.com/FJdle9E.jpg', File.join(dir, 'warm_bread.jpg'), 'kvort', at_time(11, 15))
end

def create_post(text, author, timestamp, photo, likes = [])
  post = StreamPost.create(text: text, author: author, timestamp: timestamp, photo: photo)
  unless post.valid?
    puts "Errors for post #{text}: #{post.errors.full_messages}"
    return post
  end
  likes.each do |like_user|
    post.add_like like_user
  end
  post.save!
  post
end

StreamPost.delete_all

if StreamPost.count == 0
  create_post 'This is a cute cat #catphotos', 'james', at_time(14, 31, offset:-1.day), photos[0].id, ['steven']
  create_post 'Joco is the best cruise ever #jococruise', 'steve', at_time(10, 9), nil
  create_post 'This cruise is coming up really soon #jococruise', 'james', at_time(10, 12), nil

  create_post 'The bread is warm #warmbread', 'james', at_time(10, 13), nil
  create_post 'Whats with the #warmbread meme?', 'steve', at_time(10, 14), nil, ['james']
  create_post 'This is a mean cat #catphotos', 'steve', at_time(12, 1), photos[1].id
  create_post 'This is a tired cat #catphotos', 'james', at_time(12, 6), photos[2].id, ['steven']

  create_post 'Look at this #warmbread', 'kvort', at_time(11, 15), photos[3].id
  create_post 'Wow, that bread is warm #warmbread', 'james', at_time(11, 16), nil, %w(kvort steven)
  create_post 'I miss netflix.', 'steve', at_time(11, 17), nil, %w(kvort james)

  create_post 'Are you, are you #mockingjay', 'kvort', at_time(11, 18), photos[3].id, %w(james steven)
  create_post 'Coming to the tree #mockingjay', 'james', at_time(11, 19), nil
  create_post 'Where they strung up a man they say murdered three #mockingjay', 'steve', at_time(11, 20), nil

  create_post 'Strange things did happen here #mockingjay', 'james', at_time(11, 21), nil
  create_post 'No stranger would it be #mockingjay', 'kvort', at_time(11, 22), nil
  create_post 'If we met at midnight in the hanging tree #mockingjay', 'steve', at_time(11, 23), nil

  create_post 'Are you, are you #mockingjay', 'kvort', at_time(11, 21), nil
  create_post 'Coming to the tree #mockingjay', 'steve', at_time(11, 22), nil
  create_post 'Where the dead man called out for his love to flee #mockingjay', 'james', at_time(11, 23), nil

  create_post 'Are you, are you #mockingjay', 'kvort', at_time(11, 21), nil
  create_post 'Coming to the tree #mockingjay', 'steve', at_time(11, 22), nil
  create_post 'Where the dead man called out for his love to flee #mockingjay', 'james', at_time(11, 23), nil


  create_post 'Are you, are you #mockingjay', 'james', at_time(11, 24), nil
  create_post 'Coming to the tree #mockingjay', 'kvort', at_time(11, 25), nil
  create_post 'Where the dead man called out for his love to flee #mockingjay', 'steve', at_time(11, 26), nil

  create_post 'Nike+ bracelet thingie verdict: it successfully guilted me into learning guitar by fighting zombies.', 'steve', at_time(11, 27), nil
  create_post 'I may have eaten too much #cake.', 'kvort', at_time(11, 28), nil, %w(james)
  create_post '@kvort you can never have too much #cake.', 'steve', at_time(11, 29), nil, %w(kvort)
  create_post '@kvort though you can never eat to much #cookies', 'james', at_time(11, 30), nil, %w(steven)
  create_post '@james challenge accepted.', 'kvort', at_time(11, 31), nil, %w(james steven)
  create_post 'Whats the over/under?', 'steve', at_time(11, 32), nil, %w(kvort james steven)
end