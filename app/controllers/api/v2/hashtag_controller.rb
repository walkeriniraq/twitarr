class API::V2::HashtagController < ApplicationController
  # noinspection RailsParamDefResolve
  skip_before_action :verify_authenticity_token

  def populate_hashtags
    Hashtag.repopulate_hashtags
    values = Rails.cache.fetch('hash_tag:index', expires_in: 10.seconds) do
      puts 'Cache Miss for index!'
      Hashtag.all.map {|ht| ht.name }
    end
    render json: {values: values}
  end


  def auto_complete
    query = params[:query]
    unless query && query.size >= Hashtag::MIN_AUTO_COMPLETE_LEN
      render json: {error: "Min size is #{Hashtag::MIN_AUTO_COMPLETE_LEN}", values: []}
      return
    end
    ##Rails.cache.delete("hash_tag:ac:#{query}")
    # values = Rails.cache.fetch("hash_tag:ac:#{query}", expires_in: 10.seconds) do
    #   #puts "cache miss: #{query}"
    #   Hashtag.auto_complete(query).map{|e|e}
    # end
    values = Hashtag.auto_complete(query).map{|e|e[:id]}
    render json: {values: values}
  end


end