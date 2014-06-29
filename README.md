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

Mongo

You will need to make the config/application.yml and config/mongoid.yml files.
There's already an example with some good defaults in config/*_example.yml, you just values for your isntance. You
can generate a rails secret token using the command "rake secret".

This was originally compatible in both MRI and JRuby - in theory it still is although it might require a little effort to
get the image gems working in both. Anyone who wants to put in the effort is welcome to.