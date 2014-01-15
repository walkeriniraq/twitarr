class PhotoController < ApplicationController

  def preview
    #TODO: check if the photo exists
    @photo = params[:photo]
    render :layout => false
  end

end
