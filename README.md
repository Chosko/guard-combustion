# Guard::Combustion

This guard allows you to easily develop Rails engines with [Combustion](https://github.com/pat/combustion) with no need to restart the dummy application after every change.


## Install

Make sure you have [guard](http://github.com/guard/guard) installed and Combustion fully configured on your Rails engine.

Install the gem with:

    gem install guard-combustion

Or add it to your Gemfile:

    gem 'guard-combustion'

And then add a basic setup to your Guardfile:

    guard init combustion
