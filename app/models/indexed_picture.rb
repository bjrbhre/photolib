#==============================================================================
# IndexedPicture represents a picture indexed from localhost path
#
# It has a host field and its path is absolute.
# Its url is computed on-the-fly (using file scheme).
#
# Fields
# - host: id of host where it was locally indexed
# - path: must be absolute
#
# Relations:
# - belongs to imported_picture: library picture with matching md5
#
# Indexes:
# - host + path: uniqueness of absolute path in the scope of host
#==============================================================================
class IndexedPicture
  include PictureBase

  field :host

  validate :path_is_absolute
  validates_uniqueness_of :path, scope: :host
  index({ host_id: 1, path: 1 }, unique: true)

  belongs_to :imported_picture

  def url
    "#{scheme}://0.0.0.0#{path}"
  end

  def scheme
    'file'
  end
end
