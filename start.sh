#!/bin/bash

set -e
set -x

# get the lay of the land
pwd
ls -al
env

which rake
which rails

# docker passes in the linked mongo container by environment variables.
# plug it into mongoid.yml here
sed -e "s/127.0.0.1:27017/${MONGO_PORT#tcp://}/" config/mongoid-example.yml > config/mongoid.yml

# setup steps (which we only need to do once)
rake db:mongoid:create_indexes
rake db:seed

# bind to all interfaces (this exposes ports out to docker)
rails server -b 0.0.0.0
