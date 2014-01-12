#
# This class contains some useful functions to automatically manage the interaction between combustion and guard.
# 
# @author [chosko]
# 
class CombustionHelper

  #
  # A default port for combustion
  # 
  @@default_port = 9292

  #
  # This variable records the last time that combustion was started
  # 
  @@last_start = Time.now - 5

  #
  # The pid file path
  # 
  @@combustion_pid_file = "./tmp/.combustion_pid"

  #
  # The .guard_combustion_port file path
  # 
  @@guard_combustion_port = ".guard_combustion_port"

  class << self
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
          puts "\033[22;31msomething went wrong, likely combustion was not started\x1b[0m"
        else
          puts "\033[22;32mcombustion started with pid #{pid} and listening on port #{combustion_port}\x1b[0m"
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
        puts "\033[22;31mcombustion stopped\x1b[0m"
        delete_combustion_pid
      end
    end

    #
    # Restart combustion
    # 
    def restart_combustion
      if Time.now > @@last_start + 1 # Check if the server started less than a second ago
        puts "\033[01;33mrestarting combustion...\x1b[0m"
        stop_combustion
        start_combustion
      end
    end

  private

    #
    # Write the port that will be used by combustion into .guard_combustion_port
    # 
    def set_guard_combustion_port
      file = File.open(@@guard_combustion_port, "w")
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
        if File.exists? @@guard_combustion_port
          file = File.open(@@guard_combustion_port, "r")
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
        if File.exists? @@combustion_pid_file
          file = File.open(@@combustion_pid_file, "r")
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
      if File.exists? @@combustion_pid_file
        File.delete(@@combustion_pid_file)
      end
    end

    #
    # Return a string with the shell command used for starting combustion
    # 
    def combustion_cmd combustion_port
      "rackup -p #{combustion_port} -D -P #{@@combustion_pid_file}"
    end
  end
end