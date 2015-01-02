class API::V2::SearchController < ApplicationController
  include Twitter::Extractor

  PAGE_SIZE = 20

  # noinspection RailsParamDefResolve
  skip_before_action :verify_authenticity_token

  def search
    unless params[:query]
      render json: {error: 'Required parameter \'query\' not set.'}, status: :bad_request
      return
    end
    params[:current_username] = current_username
    limit = (params[:limit] || PAGE_SIZE).to_i
    start_loc = (params[:page] || 0).to_i * limit

    search_op = StreamPost.build_search_object(params)

    render json: {stream_posts: do_search(params, StreamPost, limit, start_loc) { |e| e.decorate.to_hash(current_username) },
                  forum_posts: do_search(params, Forum, limit, start_loc) { |e| e.decorate.to_meta_hash },
                  users: do_search(params, User, limit, start_loc) { |e| e.decorate.gui_hash },
                  seamails: do_search(params, Seamail, limit, start_loc) { |e| e.decorate.to_meta_hash },
                  query: {text: search_op[:text],
                          hash_tags: search_op[:hash_tags],
                          screenames: search_op[:screenames]}}
  end


  def do_search(params, collection, limit, start_loc, &block)
    query = collection.search(params).limit(limit).skip(start_loc)
    matches = query.map { |e| yield e }
    more = (start_loc + limit < query.length)
    {matches: matches, count: query.length, more: more}
  end

end