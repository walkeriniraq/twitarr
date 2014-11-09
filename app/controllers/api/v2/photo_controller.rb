require 'tempfile'
class API::V2::PhotoController < ApplicationController
  skip_before_action :verify_authenticity_token

  PAGE_LENGTH = 20
  before_filter :login_required
  before_filter :fetch_photo, :except => [:index]

  def login_required
    head :unauthorized unless logged_in?
  end

  def fetch_photo
    begin
      @photo = PhotoMetadata.find(params[:id])
    rescue Mongoid::Errors::DocumentNotFound
      raise ActionController::RoutingError.new('Not Found') unless @photo
    end
  end

  def index
    sort_by = (params[:sort_by] || 'upload_time').to_sym
    order = (params[:order] || 'asc').to_sym
    page = params[:page].to_i
    query = PhotoMetadata.where({}).order_by([sort_by, order]).skip(PAGE_LENGTH * page).limit(PAGE_LENGTH)
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

  def update
    puts params
    if params[:photo].keys != [:original_filename]
      raise ActionController::RoutingError.new('Unable to modify fields other than original_filename') unless @photo
    end

    respond_to do |format|
      if @photo.update_attributes!(params[:photo].inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo})
        format.json { head :no_content, status: :ok }
        format.xml { head :no_content, status: :ok }
      else
        format.json { render json: @photo.errors, status: :unprocessable_entity }
        format.xml { render xml: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
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
