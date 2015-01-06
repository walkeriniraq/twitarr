module Postable
  def self.included(base)
    base.send :include, InstanceMethods
    base.extend ClassMethods
  end

  module InstanceMethods
    include Twitter::Extractor
    def validate_author
      return if author.blank?
      unless User.exist? author
        errors[:base] << "#{author} is not a valid username"
      end
    end

    def author=(username)
      super User.format_username username
    end


    def add_like(username)
          self.class.where(id: id).
          find_and_modify({ '$addToSet' => { lk: username } }, new: true)
    end

    def remove_like(username)
          self.class.where(id: id).
          find_and_modify({ '$pull' => { lk: username } }, new: true)
    end

    def likes
      self.likes = [] if super.nil?
      super
    end

    # noinspection RubyResolve
    def parse_hash_tags
      self.entities = extract_entities_with_indices text
      self.hash_tags = []
      self.mentions = []
      entities.each do |entity|
        if entity.has_key? :hashtag
          self.hash_tags << entity[:hashtag]
        elsif entity.has_key? :screen_name
          self.mentions << entity[:screen_name]
        end
      end
    end

    def post_create_operations
      increment_mentions_counts
      record_hashtags
    end

    def increment_mentions_counts
      unknown_users = []
      self.mentions.each { |mentioned_user|
        begin
          User.inc_mentions mentioned_user
        rescue Mongoid::Errors::DocumentNotFound => e
          unknown_users.push mentioned_user
        rescue => e
          logger.info "Unable to increment mention for user: #{mentioned_user}: #{e.class.name}: #{e.message}"
        end
      }
      logger.info "Unable to find mentioned user(s) #{unknown_users.join ','} to increment mention count" unless unknown_users.empty?
    end

    def record_hashtags
      self.hash_tags.each do |ht|
        Hashtag.add_tag ht
      end
    end
  end

  module ClassMethods
    def view_mentions(params = {})
      query_string = params[:query]
      start_loc = params[:page] || 0
      limit = params[:limit] || 20
      query = if params[:mentions_only]
                where({mentions: query_string})
              else
                self.or({mentions: query_string}, {author: query_string})
              end
      if params[:after]
        query = query.where(:timestamp.gt => params[:after])
      end
      query.order_by(timestamp: :desc).skip(start_loc*limit).limit(limit)
    end
  end
end
