class PhotoController < ApplicationController

  def upload
    return render_json status: 'Must provide photos to upload.' if params[:files].blank?
    files = params[:files].map do |file|
      PhotoStore.instance.upload(file, current_username)
    end
    if browser.ie?
      render text: { files: files }.to_json
    else
      render_json files: files
    end
  end

  def small_thumb
    photo = PhotoMetadata.find params[:id]
    expires_in 30.days, public: true
    response.headers['Etag'] = params[:id]
    send_file PhotoStore.instance.sm_thumb_path photo.store_filename
  end

  def medium_thumb
    photo = PhotoMetadata.find params[:id]
    expires_in 30.days, public: true
    response.headers['Etag'] = params[:id]
    send_file PhotoStore.instance.md_thumb_path photo.store_filename
  end

  def full
    photo = PhotoMetadata.find params[:id]
    expires_in 30.days, public: true
    response.headers['Etag'] = params[:id]
    send_file PhotoStore.instance.photo_path(photo.store_filename), filename: photo.original_filename, disposition: :inline
  end

end
