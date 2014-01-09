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


## Integration with guard-rspec

If you are using guard-rspec, maybe you want to stop Combustion while running tests,
just to avoid conflicts with the instance of Combustion created by Rspec.

For doing that, you have to add theese lines into the `guard :rspec` block

    callback(:run_all_begin) { CombustionHelper.stop_combustion }
    callback(:run_on_modifications_begin) { CombustionHelper.stop_combustion }
    callback(:run_all_end) { CombustionHelper.start_combustion }
    callback(:run_on_modifications_end) { CombustionHelper.start_combustion }