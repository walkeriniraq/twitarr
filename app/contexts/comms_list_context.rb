class CommsListContext
  include HashInitialize

  attr :announcement_list, :posts_index, :post_store

  TIME_ZERO = 0

  def call
    announcements = announcement_list[0, 20].map { |x| AnnouncementRole.new x }
    posts = posts_index[0, 20].map { |x| PostRole.new post_store.get(x) }
    count = announcements.count + posts.count
    announcements = announcements.each
    posts = posts.each
    [count, 20].min.times.map do
      announcement_time = announcements.peek.time_plus_offset rescue TIME_ZERO
      post_time = posts.peek.post_time rescue TIME_ZERO
      if post_time > announcement_time
        posts.next.to_entry
      else
        announcements.next.to_entry
      end
    end
  end

  class PostRole < SimpleDelegator
    def type
      :post
    end

    def to_entry
      Entry.new entry_id: post_id,
                type: type,
                time: post_time,
                from: username,
                message: message
    end
  end

  class AnnouncementRole < PostRole
    def type
      :announcement
    end

    def time_plus_offset
      __getobj__.post_time + (time_offset || 0)
    end
  end

end
