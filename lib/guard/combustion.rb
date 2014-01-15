require 'guard'
require 'guard/plugin'
require 'guard/combustion/version'
require 'guard/combustion/combustion_helper'

# 
# The guard module
# 
# @author [chosko]
# 
module Guard

  # 
  # The Guard::Combustion class
  # 
  # @author [chosko]
  #   
  class Combustion < Plugin

    def initialize (options = {})
      super
      CombustionHelper.set_options(options)
    end

    def start
      ::Guard::UI.info "Guard::Combustion is running"
      CombustionHelper.start_combustion
    end
 
    def stop
      CombustionHelper.stop_combustion
    end
 
    def reload
      CombustionHelper.restart_combustion
    end
 
    def run_all
      reload
    end
 
    def run_on_change(paths)
      reload
    end
  end
end