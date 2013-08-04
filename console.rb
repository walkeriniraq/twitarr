require 'kul'
require 'server'
require 'models/user'
require 'models/message'
require 'models/post'
require 'models/announcement'

# TODO: this doesn't work - things to figure out later
# r = Redis.new host: 'gremlin'

# r.keys 'system:*'
# r.keys 'tag:*'
# r.keys 'post:*'
# r.keys 'user:*'
# r.keys 'announcement:*'

# r.zadd 'tag:@kvort', Time.now.to_i, '12348'
# r.zrange('tag:@kvort', -10, -1, { :with_scores => true }).map { |k, v| [k, Time.at(v)] }

