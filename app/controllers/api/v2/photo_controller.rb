require 'tempfile'
# noinspection RailsParamDefResolve,RubyResolve
class API::V2::PhotoController < ApplicationController
  skip_before_action :verify_authenticity_token

  PAGE_LENGTH = 20
  before_filter :login_required, :only => [:create, :destroy, :update]
  before_filter :fetch_photo, :except => [:index, :create]

  def login_required
    head :unauthorized unless logged_in? || valid_key?(params[:key])
  end

  def fetch_photo
    begin
      @photo = PhotoMetadata.find(params[:id])
    rescue Mongoid::Errors::DocumentNotFound
      render status:404, json:{status:'Not found', id: params[:id], error: "Photo by id #{params[:id]} is not found."}
    end
  end

  def index
    sort_by = (params[:sort_by] || 'upload_time').to_sym
    order = (params[:order] || 'asc').to_sym
    page = params[:page].to_i
    query = PhotoMetadata.all.order_by([sort_by, order]).skip(PAGE_LENGTH * page).limit(PAGE_LENGTH)
    count = query.length
    result = [status: 'ok', total_count:count, page:page, items:query.length, photos:query]
    respond_to do |format|
      format.json { render json: result }
      format.xml { render xml: result }
    end
  end

  def show
    respond_to do |format|
      format.json { render json: @photo }
      format.xml { render xml: @photo }
    end
  end

  def create
    return render_json status: 'Must provide photos to upload.' if params[:files].blank? && params[:file].blank?
    if params[:files].blank?
      params[:files] = params[:file]
    end
    params[:files] = [params[:files]] if params[:files].is_a? ActionDispatch::Http::UploadedFile
    files = params[:files].map do |file|
      PhotoStore.instance.upload(file, current_username)
    end
    if browser.ie?
      render text: { files: files }.to_json
    else
      render_json files: files
    end
  end

  def update
    if params[:photo].keys != [:original_filename]
      raise ActionController::RoutingError.new('Unable to modify fields other than original_filename')
    end

    unless @photo.uploader == current_username or is_admin?
      err = [{error: "You can not update other users' photos"}]
      return respond_to do |format|
        format.json { render json: err, status: :forbidden }
        format.xml { render xml: err, status: :forbidden }
      end
    end

    respond_to do |format|
      if @photo.update_attributes!(params[:photo].inject({}) { |memo, (k, v)| memo[k.to_sym] = v; memo })
        format.json { head :no_content, status: :ok }
        format.xml { head :no_content, status: :ok }
      else
        format.json { render json: @photo.errors, status: :unprocessable_entity }
        format.xml { render xml: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    unless @photo.uploader == current_username or is_admin?
      err = [{error:"You can not delete other users' photos"}]
      return respond_to do |format|
        format.json { render json: err, status: :forbidden }
        format.xml { render xml: err, status: :forbidden }
      end
    end
    begin
      File.delete @photo.store_filename
    rescue => e
      puts "Error deleting file: #{e.to_s}"
    end
    respond_to do |format|
      if @photo.destroy
        format.json { head :no_content, status: :ok }
        format.xml { head :no_content, status: :ok }
      else
        format.json { render json: @photo.errors, status: :unprocessable_entity }
        format.xml { render xml: @photo.errors, status: :unprocessable_entity }
      end
    end
  end
end
