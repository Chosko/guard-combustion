#
# This class contains some useful functions to automatically manage the interaction between combustion and guard.
# 
# @author [chosko]
# 
class CombustionHelper

  #
  # Default options
  # 
  DEFAULTS = {
    # The file where is stored the pid of combustion
    combustion_pid_file: "./tmp/.combustion_pid",

    # The file where is stored the port used by combustion
    guard_combustion_port_file: ".guard_combustion_port",
    
    # Coloured prints
    colors: true
  }.freeze

  #
  # The options for combustion
  # 
  @@options = DEFAULTS

  #
  # A default port for combustion
  # 
  @@default_port = 9292

  #
  # This variable records the last time that combustion was started
  # 
  @@last_start = Time.now - 5

  class << self
    #
    # Set the options for combustion
    # 
    def set_options(options = {})
      @@options = _deep_merge(DEFAULTS, options).freeze
    end

    #
    # Start combustion
    # 
    def start_combustion
      if get_combustion_pid.nil?
        puts "starting combustion..."
        combustion_port = get_guard_combustion_port
        `#{combustion_cmd(combustion_port)}`
        sleep(1)
        @@last_start = Time.now
        pid = get_combustion_pid
        if pid.nil?
          puts strcolor("something went wrong, likely combustion was not started", "red")
        else
          puts strcolor("combustion started with pid #{pid} and listening on port #{combustion_port}", "green")
        end
      else
        puts "another instance of combustion is already running with pid #{pid}"
        restart_combustion
      end
    end

    #
    # Stop combustion
    # 
    def stop_combustion
      puts "stopping combustion..."
      pid = get_combustion_pid
      if pid.nil?
        puts "no instances of combustion were found"
      else
        `kill -9 #{pid}`
        puts strcolor("combustion stopped", "red")
        delete_combustion_pid
      end
    end

    #
    # Restart combustion
    # 
    def restart_combustion
      if Time.now > @@last_start + 1 # Check if the server started less than a second ago
        puts strcolor("restarting combustion...", "yellow")
        stop_combustion
        start_combustion
      end
    end

  private


    # 
    # Make a string colored
    # @param  string [String] The string to make colored
    # @param  color=nil [String] The name of the color (e.g. 'yellow')
    # 
    # @return [String] the input string colored
    def strcolor(string, color=nil)
      return string if !@@options[:colors] || color.nil?

      case color
      when "green"
        "\033[22;32m#{string}\x1b[0m"
      when "red"
        "\033[22;31m#{string}\x1b[0m"
      when "yellow"
        "\033[01;33m#{string}\x1b[0m"
      else
        string
      end
    end

    # 
    # Recursively merge two hashes, with major priority for the second hash
    # @param  hash1 [Hash] The first hash
    # @param  hash2 [Hash] The second hash
    # 
    # @return [Hash] The merged hash
    def _deep_merge(hash1, hash2)
      hash1.merge(hash2) do |key, oldval, newval|
        if oldval.instance_of?(Hash) && newval.instance_of?(Hash)
          _deep_merge(oldval, newval)
        else
          newval
        end
      end
    end

    #
    # Write the port that will be used by combustion into .guard_combustion_port
    # 
    def set_guard_combustion_port
      file = File.open(@@options[:guard_combustion_port_file], "w")
      file.write(@@default_port.to_s)
      file.close
      @@default_port
    end

    #
    # Read the port from .guard_combustion_port
    # 
    # If .guard_combustion_port doesn't exists, create it and fill it with the default port.
    # 
    def get_guard_combustion_port
      begin
        if File.exists? @@options[:guard_combustion_port_file]
          file = File.open(@@options[:guard_combustion_port_file], "r")
          contents = file.read
          combustion_port = Integer(contents.split("\n")[0])
          file.close
          combustion_port
        else
          set_guard_combustion_port
        end
      rescue ArgumentError => e
        file.close
        set_guard_combustion_port
      end
    end

    # 
    # Read combustion's pid from .combustion_pid
    # 
    def get_combustion_pid
      begin
        if File.exists? @@options[:combustion_pid_file]
          file = File.open(@@options[:combustion_pid_file], "r")
          contents = file.read
          combustion_pid = Integer(contents.split("\n")[0])
          file.close
          combustion_pid
        else
          nil
        end
      rescue ArgumentError => e
        file.close
        nil
      end
    end

    # 
    # Delete .combustion_pid
    # 
    def delete_combustion_pid
      if File.exists? @@options[:combustion_pid_file]
        File.delete(@@options[:combustion_pid_file])
      end
    end

    #
    # Return a string with the shell command used for starting combustion
    # 
    def combustion_cmd combustion_port
      "rackup -p #{combustion_port} -D -P #{@@options[:combustion_pid_file]}"
    end
  end
end