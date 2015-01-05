#==============================================================================
# PictureBase model:
# - captured_at: timestamp, extracted from exif['DateTimeOriginal']
# - exif: exif meta informations stored as a hash
# - md5: file hexdigest
# - path: path to original filename when first indexed
# - is_missing: flag set to true if file is reported missing
#
# Known exif entires:
#   "ApertureValue"
#   "BrightnessValue"
#   "ColorSpace"
#   "ComponentsConfiguration"
#   "Compression"
#   "DateTime"
#   "DateTimeDigitized"
#   "DateTimeOriginal"
#   "ExifImageLength"
#   "ExifImageWidth"
#   "ExifOffset"
#   "ExifVersion"
#   "ExposureMode"
#   "ExposureProgram"
#   "ExposureTime"
#   "Flash"
#   "FlashPixVersion"
#   "FNumber"
#   "FocalLength"
#   "FocalLengthIn35mmFilm"
#   "GPSAltitude"
#   "GPSAltitudeRef"
#   "GPSImgDirection"
#   "GPSImgDirectionRef"
#   "GPSInfo"
#   "GPSLatitude"
#   "GPSLatitudeRef"
#   "GPSLongitude"
#   "GPSLongitudeRef"
#   "GPSTimeStamp"
#   "ISOSpeedRatings"
#   "JPEGInterchangeFormat"
#   "JPEGInterchangeFormatLength"
#   "Make"
#   "MakerNote"
#   "MeteringMode"
#   "Model"
#   "Orientation"
#   "ResolutionUnit"
#   "SceneCaptureType"
#   "SceneType"
#   "SensingMethod"
#   "ShutterSpeedValue"
#   "Software"
#   "SubjectArea"
#   "SubSecTimeDigitized"
#   "SubSecTimeOriginal"
#   "WhiteBalance"
#   "XResolution"
#   "YCbCrPositioning"
#   "YResolution"
#   "DigitalZoomRatio"
#   "ExposureBiasValue"
#   "GPSDateStamp"
#   "GPSSpeed"
#   "GPSSpeedRef"
#   "GPSDestBearing"
#   "GPSDestBearingRef"
#==============================================================================
module PictureBase
  extend ActiveSupport::Concern

  included do
    extend ClassMethods
    include Mongoid::Document
    include Mongoid::Timestamps

    field :captured_at, type: Time
    field :exif, type: Hash
    field :md5, type: String
    field :is_missing, type: Boolean, default: false
    field :path, type: String

    after_initialize :set_computed_fields
  end

  COMPUTED_FIELDS = %i(exif captured_at md5)

  def captured_at_string(format = '%Y-%m-%d')
    captured_at.strftime(format) if captured_at
  end

  def check_is_missing
    update_attribute(:is_missing, !file_exist?)
    is_missing
  end

  def reset_computed_fields
    COMPUTED_FIELDS.each { |field| send("#{field}=", nil) }
    set_computed_fields
  end

  def file_exist?
    path && File.exist?(absolute_path)
  end

  def absolute_path
    File.expand_path(path)
  end

  #==========================================================================
  # Private scope
  #==========================================================================

  private

  def path_is_absolute
    absolute_path == path
  end

  def path_is_relative
    # path does not start with /
    path =~ /[^\/]/
  end

  def set_computed_fields
    COMPUTED_FIELDS.each { |field| send("set_#{field}") }
  end

  def set_captured_at
    self.captured_at ||= Time.strptime(
      "#{exif['DateTimeOriginal']} #{self.class.default_time_zone}",
      '%Y:%m:%d %H:%M:%S %z'
    ) if exif && exif['DateTimeOriginal']
  end

  def set_exif
    self.exif ||= begin
      image = Magick::Image.read(path).first
      Hash[image.get_exif_by_entry]
    end if file_exist?
  end

  def set_md5
    self.md5 ||= Digest::MD5.hexdigest(File.read(path)) if file_exist?
  end

  #==========================================================================
  # Class Methods
  #==========================================================================
  module ClassMethods
    def default_time_zone
      Application.config['models']['pictures']['default_time_zone']
    end
  end
end
