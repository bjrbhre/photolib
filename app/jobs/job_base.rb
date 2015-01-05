module Jobs
  #============================================================================
  # JobsBase
  # - configuration and logger
  # - perform options
  #============================================================================
  class JobBase
    attr_accessor :config,
                  :logger

    def initialize(config = {})
      init_config(config)
      init_logger
    end

    def perform(options = {})
      update_config(options)
    end

    #==========================================================================
    # Private scope
    #==========================================================================

    private

    #==========================================================================
    # Init and Configuration
    #==========================================================================
    def config_basename
      self.class.name.split('::')[-1].underscore
    end

    def default_config
      Application.config['jobs'][config_basename] || {}
    end

    def init_config(options)
      @config = Utils.convert_hash_with_symbols_as_key(
        default_config.merge(options)
      )
    end

    def update_config(options)
      @config.merge!(Utils.convert_hash_with_symbols_as_key(options))
    end

    def init_logger
      @logger = Utils.create_logger(self.class.name)
    end
  end
end # module Jobs
