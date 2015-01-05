require 'jobs/job_base'

module Jobs
  #============================================================================
  # Jobs::PicturesImporter
  # import picture files from indexed pictures
  #============================================================================
  class PicturesImporter < JobBase
    def perform(options = {})
      super(options)
      logger.info("[perform] #{ImportedPicture.count} pictures in library")
      logger.info('[perform] rebuild library') if rebuild_library

      import_pictures
      check_missing_library_files if rebuild_library

      logger.info("[perform] #{ImportedPicture.count} pictures in library")
    end

    #==========================================================================
    # Private scope
    #==========================================================================

    private

    def import_pictures
      query = rebuild_library ? {} : { imported_picture: nil }
      indexed_pictures = IndexedPicture.where(query)
      count = indexed_pictures.count
      logger.info("[import_pictures] #{count} pictures to import")

      progress_bar = Utils::ProgressBar.create(total: count)
      indexed_pictures.each do |indexed_picture|
        progress_bar.increment
        imported_picture = import_picture(indexed_picture)
        import_file(indexed_picture, imported_picture)
      end
    end

    def import_picture(indexed_picture)
      # Fetch existing picture with same digest
      # Return existing picture or create a new one

      attributes = { _id: indexed_picture.md5 }
      picture = ImportedPicture.where(attributes).first
      if picture
        picture.indexed_pictures << indexed_picture
      else
        picture = ImportedPicture.new_from_picture(indexed_picture)
      end
      picture.save! ? picture : nil
    end

    def import_file(indexed_picture, imported_picture)
      filename_from = indexed_picture.path
      filename_to = imported_picture.absolute_path
      return if indexed_picture.check_is_missing
      unless File.exist?(filename_to)
        directory = File.dirname(filename_to)
        FileUtils.mkdir_p(directory) unless File.directory?(directory)
        FileUtils.cp(filename_from, filename_to)
      end
      imported_picture.check_is_missing
    end

    def check_missing_library_files
      logger.info('[check_missing_library_files]')
      pictures = ImportedPicture.all
      progress_bar = Utils::ProgressBar.create(total: pictures.count)
      pictures.each do |p|
        progress_bar.increment
        p.check_is_missing
      end
    end

    def rebuild_library
      config[:rebuild] && config[:rebuild].downcase == 'rebuild'
    end
  end
end # module Jobs
