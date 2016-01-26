require 'digest'
require 'RMagick'
require 'singleton'

class PhotoStore
  include Singleton

  SMALL_PROFILE_PHOTO_SIZE = 200
  LARGE_PROFILE_PHOTO_SIZE = 1000
  SMALL_IMAGE_SIZE = 500
  MEDIUM_IMAGE_SIZE = 1600

  def upload(temp_file, uploader)
    temp_file = UploadFile.new(temp_file)
    return { status: 'File was not an allowed image type - only jpg, gif, and png accepted.' } unless temp_file.photo_type?
    existing_photo = PhotoMetadata.where(md5_hash: temp_file.md5_hash).first
    return { status: 'File has already been uploaded.', photo: existing_photo.id.to_s } unless existing_photo.nil?
    begin
      img = read_image(temp_file)
    rescue Java::JavaLang::NullPointerException
      # yeah, ImageMagick throws a NPE if the photo isn't a photo
      return { status: 'Photo could not be opened - is it an image?' }
    end
    return { status: 'File exceeds maximum file size of 10MB' } if temp_file.tempfile.size >= 10000000 # 10MB
    photo = store(temp_file, uploader)
    img.resize_to_fit(MEDIUM_IMAGE_SIZE).write "tmp/#{photo.store_filename}"
    FileUtils.move "tmp/#{photo.store_filename}", md_thumb_path(photo.store_filename)
    img.resize_to_fill(SMALL_IMAGE_SIZE).write "tmp/#{photo.store_filename}"
    FileUtils.move "tmp/#{photo.store_filename}", sm_thumb_path(photo.store_filename)
    photo.save
    { status: 'ok', photo: photo.id.to_s }
  rescue EXIFR::MalformedJPEG
    { status: 'Photo extension is jpg but could not be opened as jpeg.' }
  end

  def read_image(temp_file)
    img = Magick::Image::read(temp_file.tempfile.path).first
    if temp_file.extension == 'jpg' || temp_file.extension == 'jpeg'
      exif = EXIFR::JPEG.new(temp_file.tempfile)
      orientation = exif.orientation
      img = orientation.transform_rmagick(img) if orientation
    end
    img
  end

  def upload_profile_photo(temp_file, username)
    temp_file = UploadFile.new(temp_file)
    return { status: 'File was not an allowed image type - only jpg, gif, and png accepted.' } unless temp_file.photo_type?
    begin
      img = read_image(temp_file)
    rescue Java::JavaLang::NullPointerException
      # yeah, ImageMagick throws a NPE if the photo isn't a photo
      return { status: 'Photo could not be opened - is it an image?' }
    end
    tmp_store_path = "#{Rails.root}/tmp/#{username}.jpg"
    img.resize_to_fit(LARGE_PROFILE_PHOTO_SIZE).write tmp_store_path
    FileUtils.move tmp_store_path, PhotoStore.instance.full_profile_path(username)
    img.resize_to_fill(SMALL_PROFILE_PHOTO_SIZE).write tmp_store_path
    FileUtils.move tmp_store_path, PhotoStore.instance.small_profile_path(username)
    { status: 'ok', md5_hash: temp_file.md5_hash }
  end

  def reset_profile_photo(username)
    identicon = Identicon.create(username)
    tmp_store_path = "#{Rails.root}/tmp/#{username}.jpg"
    identicon.resize_to_fit(LARGE_PROFILE_PHOTO_SIZE).write tmp_store_path
    FileUtils.move tmp_store_path, PhotoStore.instance.full_profile_path(username)
    identicon.resize_to_fill(SMALL_PROFILE_PHOTO_SIZE).write tmp_store_path
    small_profile_path = PhotoStore.instance.small_profile_path(username)
    FileUtils.move tmp_store_path, small_profile_path
    { status: 'ok', md5_hash: Digest::MD5.file(small_profile_path).hexdigest }
  end

  def store(file, uploader)
    new_filename = SecureRandom.uuid.to_s + Pathname.new(file.filename).extname.downcase
    animated_image = ImageHelpers::AnimatedImage.is_animated file.tempfile.path
    photo = PhotoMetadata.new uploader: uploader,
                              original_filename: file.filename,
                              store_filename: new_filename,
                              upload_time: Time.now,
                              md5_hash: file.md5_hash,
                              animated: animated_image
    FileUtils.copy file.tempfile, photo_path(photo.store_filename)
    photo
  end

  def reindex_photos
    PhotoMetadata.each do |photo|
      puts photo.store_filename
      img = Magick::Image::read(photo_path photo.store_filename).first
      extension = Pathname.new(photo.original_filename).extname[1..-1].downcase
      begin
        if extension == 'jpg' || extension == 'jpeg'
          exif = EXIFR::JPEG.new(photo_path photo.store_filename)
          orientation = exif.orientation
          img = orientation.transform_rmagick(img) if orientation
        end
      rescue => e
        puts e
      end
      img.resize_to_fill(SMALL_IMAGE_SIZE).write "#{Rails.root}/tmp/#{photo.store_filename}"
      FileUtils.move "#{Rails.root}/tmp/#{photo.store_filename}", sm_thumb_path(photo.store_filename)
    end
  end

  def reindex_profiles
    User.each do |user|
      puts user.username
      begin
        img = Magick::Image::read(full_profile_path user.username).first
        tmp_store_path = "#{Rails.root}/tmp/#{user.username}.jpg"
        img.resize_to_fill(SMALL_PROFILE_PHOTO_SIZE).write tmp_store_path
        FileUtils.move tmp_store_path, small_profile_path(user.username)
      rescue => e
        puts e
      end
    end
  end

  def initialize
    @root = Rails.root.join(Rails.configuration.photo_store)

    @full = @root + 'full'
    @thumb = @root + 'thumb'
    @profiles = @root + 'profiles/'
    @profiles_small = @profiles + 'small'
    @profiles_full = @profiles + 'full'
    @full.mkdir unless @full.exist?
    @thumb.mkdir unless @thumb.exist?
    @profiles.mkdir unless @profiles.exist?
    @profiles_small.mkdir unless @profiles_small.exist?
    @profiles_full.mkdir unless @profiles_full.exist?
  end

  def photo_path(filename)
    (build_directory(@full, filename) + filename).to_s
  end

  def sm_thumb_path(filename)
    (build_directory(@thumb, filename) + ('sm_' + filename)).to_s
  end

  def md_thumb_path(filename)
    (build_directory(@thumb, filename) + ('md_' + filename)).to_s
  end

  def small_profile_path(username)
    @profiles_small + "#{username}.jpg"
  end

  def full_profile_path(username)
    @profiles_full + "#{username}.jpg"
  end

  @@mutex = Mutex.new

  def build_directory(root_path, filename)
    @@mutex.synchronize do
      first = root_path + filename[0]
      first.mkdir unless first.exist?
      second = first + filename[1]
      second.mkdir unless second.exist?
      second
    end
  end

  class UploadFile
    PHOTO_EXTENSIONS = %w(jpg jpeg gif png).freeze

    def initialize(file)
      @file = file
    end

    def extension
      @ext ||= Pathname.new(@file.original_filename).extname[1..-1].downcase
    end

    def photo_type?
      return true if PHOTO_EXTENSIONS.include?(extension)
      false
    end

    def tempfile
      @file.tempfile
    end

    def md5_hash
      @hash ||= Digest::MD5.file(@file.tempfile).hexdigest
    end

    def filename
      @file.original_filename
    end
  end

end