class PhotoController < ApplicationController

  def preview
    #TODO: check if the photo exists
    @photo = params[:photo]
    render :layout => false
  end

  def upload
    return render_json status: 'Must provide photos to upload.' if params[:files].blank?
    store = PhotoStore.new
    files = params[:files].map do |file|
      store.upload(file, current_username)
    end
    if browser.ie?
      render text: { files: files }.to_json
    else
      render_json files: files
    end
  end

end
