[ ![Build Status](https://codeship.com/projects/e16b2de0-ba55-0133-31da-665d9895e075/status?branch=master)](https://codeship.com/projects/135667)
[![Code Climate](https://codeclimate.com/github/jamatthews/spree-subscribe/badges/gpa.svg)](https://codeclimate.com/github/jamatthews/spree-subscribe)

**This extension is ready for beta testing.**

SpreeSubscribe
==============

A Spree expension for allowing customers to make flexible subscriptions and manage them. Original work by Daniel Dixon with further work by myself and Jordan Moncharmont

Installation
-------

Add this to your Gemfile

    gem "spree_subscribe", github: "jamatthews/spree-subscribe", branch: '2-0-beta'

Install the database migrations

    rake spree_subscribe:install:migrations

Setup a cron job to run this rake task every night

    rake spree_subscribe:reorders:create

Future To-Do
-------
* Improve compatability with spree-product-assembly
* Extend Spree API to handle subscriptions
* Move Intervalable#time_title to a helper so can use time_unit_symbol to pull from localization
* Extend Spree::Admin::SubscriptionsController to include filtering and sorting
* For a reorder, if a shipping method is no longer available, select the cheapest.

Testing
-------

Be sure to bundle your dependencies and then create a dummy test app for the specs to run against.

    $ bundle
    $ bundle exec rake test_app
    $ bundle exec rspec spec

Copyright (c) 2016 Jacob Matthews, released under the New BSD License
Copyright (c) 2013 Daniel Dixon, released under the New BSD License


Responsible Disclosure of Security Issues
-------

If you find a security issue with this extension, please contact me directly (jake@subsupps.co.nz).  Do NOT post it publicly to the GitHub issues for this repo.
