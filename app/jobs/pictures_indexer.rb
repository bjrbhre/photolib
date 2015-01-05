require 'jobs/job_base'

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
  class PicturesIndexer < JobBase
    def perform(options = {})
      super(options)
      logger.info("[initialize] #{IndexedPicture.count} pictures indexed")
      logger.info('[process_matches] rebuild index') if rebuild_index

      process_matches

      logger.info("[perform] #{IndexedPicture.count} pictures indexed")
    end

    #==========================================================================
    # Private scope
    #==========================================================================

    private

    def process_matches
      root_path = File.expand_path(config[:root_path])
      matches = Dir.glob(files_pattern(root_path))
      count = matches.count
      logger.info("[process_matches] #{count} matches at [#{root_path}]")

      progress_bar = Utils::ProgressBar.create(total: count)
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

    def rebuild_index
      config[:rebuild] && config[:rebuild].downcase == 'rebuild'
    end
  end
end # module Jobs
