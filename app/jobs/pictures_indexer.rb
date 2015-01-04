module Jobs
  #============================================================================
  # Jobs::PicturesIndexer
  # index picture files starting at root_path
  #
  # config:
  # - file_extensions: array of file extensions to consider for indexation
  #
  # options:
  # - root_path: path to root directory for indexation of picture files
  #============================================================================
  class PicturesIndexer
    attr_accessor :config,
                  :logger

    def initialize(config = {})
      init_config(config)
      init_logger
      logger.info("[initialize] #{IndexedPicture.count} document(s) indexed")
    end

    def perform(options = {})
      update_config(options)

      root_path = File.expand_path(config[:root_path])
      logger.info("[perform] at [#{root_path}]")

      pattern = files_pattern(root_path)
      logger.info("[perform] matching pattern [#{pattern}]")

      matches = Dir.glob(pattern)
      logger.info("[perform] #{matches.count} matches to process")

      process_matches(matches)
      logger.info("[perform] #{IndexedPicture.count} document(s) indexed")
    end

    #==========================================================================
    # Private scope
    #==========================================================================

    private

    def process_matches(matches)
      logger.info('[process_matches] rebuild index') if rebuild_index

      progress_bar = Utils::ProgressBar.create(total: matches.count)
      matches.each do |filename|
        progress_bar.increment
        process_file(filename)
      end
    end

    def process_file(filename)
      # Fetch existing picture with same host and path
      # If index is being completely rebuilded:
      # - reset computed fields
      # Else (no complete rebuild):
      # - return existing picture or create a new one

      attributes = { host: Host.localhost, path: filename }
      picture = IndexedPicture.where(attributes).first
      return picture unless picture.nil? || rebuild_index

      if picture
        picture.reset_computed_fields
      else
        picture = IndexedPicture.new(attributes)
      end
      picture.save! ? picture : nil
    end

    def files_pattern(root_path)
      root_path = File.expand_path(root_path)
      file_extensions =  config[:file_extensions].map(&:upcase)
      file_extensions += config[:file_extensions].map(&:downcase)
      "#{root_path}/**/*.{#{file_extensions.join(',')}}"
    end

    #==========================================================================
    # Init and Configuration
    #==========================================================================
    def init_config(options)
      @config = Utils.convert_hash_with_symbols_as_key(
        Application.config['jobs']['pictures_indexer']
        .merge(options)
      )
    end

    def update_config(options)
      @config.merge!(Utils.convert_hash_with_symbols_as_key(options))
    end

    def init_logger
      @logger = Utils.create_logger(self.class.name)
    end

    def rebuild_index
      config[:rebuild] && config[:rebuild].downcase == 'rebuild'
    end
  end
end # module Jobs
