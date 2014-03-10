twitarr
=======

Twit-arr is a micro-blogging site that is set up for [JoCo Cruise Crazy](http://jococruisecrazy.com/)

Description
-----------

Twit-arr was the name for the Status.net instance brought onto the cruise ship for JCCC2 and JCCC3. Status.net being
less than optimal for this environment, I took it upon myself to build a new version, completely customized for
the cruise. It does help that I wanted to have a chance to use Ember.js and Redis in production.

This is a very non-rails-standard webapp. Most of the controller actions simply validate the incoming parameters and
then delegate to a DCI context. DCI is a great pattern for this since Redis functions are far more simple than SQL
would be. DCI also allows for complete testing of the controller action, without actually hitting the database.

At the current moment, the Rails layer needs to be cleaned up somewhat. Some parts were hacked together because I didn't
have a clear vision of the architecture at the beginning, and some parts were hacked together because I needed to get it
done before a cruise ship sailed. Most things that have a DCI context and unit tests are likely to stay though.

The Ember layer is a large question at the moment. It is very much hacked together because I had no idea how to build
an Ember app. It also doesn't have any unit testing because I didn't know how to do that either. Both of those problems
will need to be corrected. Unfortunately at this time I am not 100% certain that Ember the correct choice for a primarily
mobile environment - Android 2.3 devices in particular were incredibly slow.

Setup
-----

In order to get this codebase running, you will need a Redis instance. Redis has the single best installation instructions
ever, and they are [here](http://redis.io/topics/quickstart). Don't forget to point your development config at your Redis
instance or you will get very angry controller exceptions.

You will also need to generate your own secret token, because that should NEVER BE CHECKED IN TO SOURCE CONTROL. If you
forget how, there's a secret_token_example file in the config/initializers folder that has instructions. (I always forget)
