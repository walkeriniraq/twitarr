# twitarr

Twit-arr is a micro-blogging site that is set up for [JoCo Cruise Crazy](http://jococruisecrazy.com/)

## Description

Twit-arr was the name for the Status.net instance brought onto the cruise ship for JCCC2 and JCCC3. Status.net being
less than optimal for this environment, I took it upon myself to build a new version, completely customized for
the cruise. It does help that I wanted to have a chance to use Ember.js and Mongodb in production.

## Setup

Mongo

You will need to make the config/application.yml and config/mongoid.yml files.
There's already an example with some good defaults in config/*_example.yml, you just values for your instance. You
can generate a rails secret token using the command "rake secret".

This was originally compatible in both MRI and JRuby - in theory it still is although it might require a little effort to
get the image gems working in both. Anyone who wants to put in the effort is welcome to.

## Quick Developer Setup

### Prereqs

You require `java version 1.6+` in order to use this.

Then you will need `jruby` installed.  The easiest way to do this is to install it via [RVM](http://rvm.io/).

To install [RVM](http://rvm.io/) run:

```
  $ \curl -sSL https://get.rvm.io | bash -s stable
```

Then install `jruby` via [RVM](http://rvm.io/):

```
  $ rvm install jruby
```

Then in the future terminal sessions, you can use `rvm use` to set the terminal session enviorment to jruby:

```
  $ rvm use jruby
```

You will also need to download and run [Mongodb](http://www.mongodb.org/)

Since I like to keep my database just for this project, when I execute the mongod process I run:

```
 $ mkdir -p temp/data/db && mongod --dbpath temp/data/db --setParameter textSearchEnabled=true
```

This will create the mongo database within this project's temp directory.  The temp directory is also explictly ignored in the `.gitignore` file, so you don't have to worry about checking it in.

### Project setup
First you will need to run:

```
  $ bundle install
```

Then you will need to setup the application's secret token and mongoid configuration:

```
   $ echo "SECRET_TOKEN: '$(rake secret)'" > config/application.yml
   $ cp config/mongoid-example.yml config/mongoid.yml
```

Now you have to tell mongoid to create the required indexes.  If you forget to do this you will get strange errors that claims you must have indexes created in order to perform text searches.

```
  $ rake db:mongoid:create_indexes
```

Now you can seed the database with some initial data:

```
  $ rake db:seed
```

This will create 3 users.  Each of the users' password is the same as their username.

1. kvort (an admin user)
2. james (a non-admin user)
3. admin (another admin user)

Now we can finally run the rails server.  By default this server can be hit from [http://localhost:3000](http://localhost:3000)

```
  $ rails server
```
