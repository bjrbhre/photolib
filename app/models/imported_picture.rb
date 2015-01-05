#==============================================================================
# ImportedPicture represents a library picture
#
# Fields:
# - _id: equal to md5
# - extension: cleaned file extension
# - path: formatted and relative to library root
#
# Relations:
# - has_many indexed_pictures: indexed pictures with matching md5
#
# Indexes:
# - path: unique inside library
#==============================================================================
class ImportedPicture
  include PictureBase

  field :_id, type: String, default: -> { md5 }
  field :extension, type: Symbol
  after_initialize :set_path

  validate :path_is_relative
  validates_uniqueness_of :path
  index({ path: 1 }, unique: true)

  has_many :indexed_pictures

  def self.new_from_picture(origin)
    return unless origin

    fields = %i(md5 exif captured_at)
    attrs = Hash[fields.map { |f| [f, origin.send(f)] }]
    attrs[:extension] = Utils.file_extension(origin.path)
    attrs[:indexed_picture_ids] = [origin.id]
    ImportedPicture.new(attrs)
  end

  def absolute_path
    "#{Library.pictures_path}/#{relative_filename}"
  end

  private

  #============================================================================
  # Library filename formatting
  #============================================================================
  def relative_dirname
    captured_at ? captured_at_string('%Y/%m/%d') : '_missing_timestamp'
  end

  def basename
    ts_format = '%Y-%m-%dT%H-%M-%S'
    ts = captured_at ? "#{captured_at_string(ts_format)}." : ''
    "#{ts}#{md5}#{extension}"
  end

  def relative_filename
    "#{relative_dirname}/#{basename}"
  end

  def set_path
    self.path ||= basename
  end
end
