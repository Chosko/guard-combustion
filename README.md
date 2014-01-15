# Guard::Combustion

This guard allows you to easily develop Rails engines with [Combustion](https://github.com/pat/combustion) with no need to manually restart the dummy application after every change.

## Install

Make sure you have [guard](http://github.com/guard/guard) installed and Combustion fully configured on your Rails engine.

Install the gem with:

    gem install guard-combustion

Or add it to your Gemfile:

    gem "guard-combustion", "~> 0.1.1"

And then add a basic setup to your Guardfile:

    guard init combustion

## Configuration

### Options

You can use some options to configure guard-combustion from the Guardfile.

#### Port

Combustion listens by default on the port 9292. To change the port, use the `:port` option. E.g.

```ruby
guard :combustion, port: 3000 do
  watch(%r{^(app|config|lib|spec)/(.*)})
end
```

#### Pid File

Guard::Combustion saves the PID of Combustion into a file when it has been just created, and deletes it when Combustion stops.

By default, the pid file is `./tmp/.combustion_pid`, but if you want to change the path, you can set the `:pid_file` option (make sure that the path already exists, or create the required directories).

```ruby
guard :combustion, pid_file: './my_dir/my_new_pid_file.example' do
  watch(%r{^(app|config|lib|spec)/(.*)})
end
```

#### Colors

If you want to turn off the colored prints, set the `:color` option to `false`

```ruby
guard :combustion, color: false do
  watch(%r{^(app|config|lib|spec)/(.*)})
end
```

#### Custom Port File

The `:port` option mentioned above is a perfect solution if you are working alone, or with people that all want to use the same listening port.

But... what if you want to use a different port from your team mates?

No worries: you can set your custom port by writing it (and only it!) into the file `.guard_combustion_port` at the root of your project. This file has major priority than the port set into the Guardfile.

.guard_combustion_port file: E.g.

        8080

If you add `.guard_combustion_port` to the `.gitignore` file, your team mates won't even notice the difference.

If you don't like to add files at the root of your project, you can also change the custom port file, setting the `:custom_port_file` option.

```ruby
guard :combustion, custom_port_file: "my_new_custom_port_file.example" do
  watch(%r{^(app|config|lib|spec)/(.*)})
end
```

### Integration with guard-rspec (or any other guard)

If you are using guard-rspec, or any other guard that uses Combustion, 
you may want to stop the server while running the tests 
to avoid conflicts with the instance of Combustion created by Rspec.

For doing that, you have to add theese lines into the `guard :rspec` block

```ruby
callback(:run_all_begin) { Guard::CombustionHelper.stop_combustion }
callback(:run_on_modifications_begin) { Guard::CombustionHelper.stop_combustion }
callback(:run_all_end) { Guard::CombustionHelper.start_combustion }
callback(:run_on_modifications_end) { Guard::CombustionHelper.start_combustion }
```

For more informations about callbacks, see https://github.com/guard/guard/wiki/Hooks-and-callbacks