require 'guard'
require 'guard/guard'
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