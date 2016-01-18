puts "Using rails env #{Rails.env}"

load(Rails.root.join('db', 'seeds', "#{Rails.env.downcase}.rb"))
