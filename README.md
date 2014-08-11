twitarr
=======

Twit-arr is a micro-blogging site that is set up for [JoCo Cruise Crazy](http://jococruisecrazy.com/)

Description
-----------

Twit-arr was the name for the Status.net instance brought onto the cruise ship for JCCC2 and JCCC3. Status.net being
less than optimal for this environment, I took it upon myself to build a new version, completely customized for
the cruise. It does help that I wanted to have a chance to use Ember.js and Redis in production.

Setup
-----

Mongo

You will need to make the config/application.yml and config/mongoid.yml files.
There's already an example with some good defaults in config/*_example.yml, you just values for your isntance. You
can generate a rails secret token using the command "rake secret".

This was originally compatible in both MRI and JRuby - in theory it still is although it might require a little effort to
get the image gems working in both. Anyone who wants to put in the effort is welcome to.