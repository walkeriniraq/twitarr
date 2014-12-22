class API::V2::SearchController < ApplicationController
  include Twitter::Extractor

  # noinspection RailsParamDefResolve
  skip_before_action :verify_authenticity_token

  def search
    query = params[:query]
    posts_after = params[:after]
    entities = extract_entities_with_indices query

    unless query
      render json:{error: 'Required parameter \'query\' not set.'}, status: :bad_request
      return
    end

    hash_tags = []
    screenames = []

    last_pos = 0
    text_buffer = ''

    entities.each do |entity|
      if entity.has_key? :hashtag
        hash_tags << entity[:hashtag]
      elsif entity.has_key? :screen_name
        screenames << entity[:screen_name]
      end
      if entity[:indices][0] - 1 > last_pos
        text_buffer = text_buffer + ' ' + query[last_pos..entity[:indices][0] - 1]
      end
      last_pos = entity[:indices][1]
    end

    if last_pos < query.length
      text_buffer = text_buffer + query[last_pos..query.length]
    elsif last_pos == 0
      text_buffer = query
    end
    text_buffer.strip!
    criteria = StreamPost
    criteria = criteria.where(:hash_tags.all => hash_tags) unless hash_tags.empty?
    criteria = criteria.where(:$or => [{:mentions.all => screenames}, {:author.in => screenames}]) unless screenames.empty?
    criteria = criteria.where(:text => Regexp.new(text_buffer)) unless text_buffer.empty?
    if posts_after
      criteria = criteria.gt(timestamp: posts_after)
    end
    criteria = criteria.limit(20)


    matches = criteria.map{|e| StreamPostDecorator.decorate(e).to_hash(current_username)}


    render json:{results: matches, count:matches.length, query:{text: text_buffer, hash_tags:hash_tags, screenames: screenames} }
  end
end