module Searchable
  def self.included(base)
    base.send :include, InstanceMethods
    base.extend ClassMethods
  end

  module InstanceMethods

  end

  module ClassMethods
    include Twitter::Extractor
    def build_search_object(params = {})
      query = params[:query]
      posts_after = params[:after]
      should_not_extract_ht = params.has_key?(:no_hashtags) and params[:no_hashtags]
      entities = extract_entities_with_indices query

      raise 'A query must be specified in order to search on posts' unless query

      hash_tags = []
      screenames = []

      last_pos = 0
      text_buffer = ''

      entities.each do |entity|
        break if should_not_extract_ht and entity.has_key? :hashtag
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

      {text: text_buffer, screenames: screenames, hash_tags: hash_tags, posts_after: posts_after, original_query: query}
    end
  end

end