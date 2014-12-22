class API::V2::SearchController < ApplicationController
  include Twitter::Extractor

  # noinspection RailsParamDefResolve
  skip_before_action :verify_authenticity_token

  def search
    unless params[:query]
      render json: {error: 'Required parameter \'query\' not set.'}, status: :bad_request
      return
    end
    params[:current_username] = current_username

    search_op = StreamPost.build_search_object(params)
    stream_matches = StreamPost.search(params).map { |e| e.decorate.to_hash(current_username) }
    forum_matches = Forum.search(params).map { |e| e.decorate.to_meta_hash }
    users_matches = User.search(params).map { |e| e.decorate.gui_hash }
    seamail_matches = Seamail.search(params).map { |e| e.decorate.to_meta_hash }

    render json: {stream_posts: {matches: stream_matches, count: stream_matches.length},
                  forum_posts: {matches: forum_matches, count: forum_matches.length},
                  users: {matches: users_matches, count: users_matches.length},
                  seamails: {matches: seamail_matches, count: seamail_matches.length },
                  query: {text: search_op[:text],
                          hash_tags: search_op[:hash_tags],
                          screenames: search_op[:screenames]}}
  end
end