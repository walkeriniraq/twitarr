class API::V2::SearchController < ApplicationController
  include Twitter::Extractor

  # noinspection RailsParamDefResolve
  skip_before_action :verify_authenticity_token

  def search
    unless params[:text]
      render json: {error: 'Required parameter \'text\' not set.'}, status: :bad_request
      return
    end
    params[:current_username] = current_username
    render json: { status: 'ok',
                   stream_posts: do_search(params, StreamPost) { |e| e.decorate.to_hash(current_username, request_options) },
                   forum_posts: do_search(params, Forum) { |e| e.decorate.to_meta_hash },
                   users: do_search(params, User) { |e| e.decorate.gui_hash },
                   seamails: do_search(params, Seamail) { |e| e.decorate.to_meta_hash },
                   events: do_search(params, Event) { |e| e.decorate.to_hash },
                   query: {text: params[:text]}}
  end


  def do_search(params, collection)
    query = collection.search(params)
    matches = query.map { |e| yield e }
    {matches: matches, count: query.length, more: query.has_more?}
  end

end
