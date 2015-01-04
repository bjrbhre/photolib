#==============================================================================
# Host model
#==============================================================================
class Host
  class << self
    def localhost
      Application.config['models']['host']['localhost']
    end
  end
end
