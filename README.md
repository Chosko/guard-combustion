# Guard::Combustion

This guard allows you to easily develop Rails engines with [Combustion](https://github.com/pat/combustion) with no need to manually restart the dummy application after every change.

<!-- MarkdownTOC -->
- [Install][install]
- Configuration
    - Combustion port
    - Integration with guard-rspec (or any other guard)
<!-- /MarkdownTOC -->

## Install[install]

Make sure you have [guard](http://github.com/guard/guard) installed and Combustion fully configured on your Rails engine.

Install the gem with:

    gem install guard-combustion

Or add it to your Gemfile:

    gem "guard-combustion", "~> 0.1.0"

And then add a basic setup to your Guardfile:

    guard init combustion

## Configuration

### Combustion port

Combustion listens on the port 9292 by default.
You can choose another port (e.g. 3000) modifying (or creating) the file `/path/to/your/engine/.guard_combustion_port`

	3001

If ".guard_combustion_port" doesn't exists, it will be generated and configured with the default port at the first use of guard-combustion.

### Integration with guard-rspec (or any other guard)

If you are using guard-rspec, or any other guard that uses Combustion, 
you may want to stop the server while running the tests 
to avoid conflicts with the instance of Combustion created by Rspec.

For doing that, you have to add theese lines into the `guard :rspec` block

    callback(:run_all_begin) { CombustionHelper.stop_combustion }
    callback(:run_on_modifications_begin) { CombustionHelper.stop_combustion }
    callback(:run_all_end) { CombustionHelper.start_combustion }
    callback(:run_on_modifications_end) { CombustionHelper.start_combustion }

For more informations about callbacks, see https://github.com/guard/guard/wiki/Hooks-and-callbacks