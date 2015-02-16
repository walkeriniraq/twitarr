class LocationController < ApplicationController

  def index
    render json: {values: Location.all.map{|loc|loc.name}}
  end

  def create
    unless is_admin?
      render json: {status: 'ERROR', error: 'Only admins may add locations'}
    end
    Location.add_location params[:name]
  end

  def delete
    unless is_admin?
      render json: {status: 'ERROR', error: 'Only admins may remove locations'}
    end
    Location.where(name: params[:name]).delete
    render json: {status: 'OK'}
  end

  def auto_complete
    query = params[:query]
    unless query && query.size >= Location::MIN_AUTO_COMPLETE_LEN
      render json: {status: 'ERROR', error: "Min size is #{Location::MIN_AUTO_COMPLETE_LEN}", values: []}
      return
    end
    values = Location.auto_complete(query).map{|e|e[:id]}
    render json: {values: values.map{|loc|loc.name}}
  end

end