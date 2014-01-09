require 'guard'
require 'guard/guard'
require 'guard/combustion/version'
require 'guard/combustion/combustion_helper'

module Guard
  class Combustion < Guard
 
    def start
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