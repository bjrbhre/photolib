#==============================================================================
# Host
#==============================================================================
module Host
  class << self
    def localhost
      Application.config['models']['hosts']['localhost']
    end
  end
end
