#==============================================================================
# Library
#==============================================================================
module Library
  class << self
    def root_path
      File.expand_path(
        Application.config['models']['libraries']['default']['root_path']
      )
    end

    def pictures_path
      "#{root_path}/pictures"
    end
  end
end
