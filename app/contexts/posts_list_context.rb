class PostsListContext
  include HashInitialize

  attr :announcement_list, :posts_index, :post_store

  TIME_ZERO = 0

  def call
    announcements = announcement_list[0, 20].map { |x| AnnouncementRole.new x }
    posts = posts_index[0, 20].map { |x| post_store.get(x) }
    count = announcements.count + posts.count
    announcements = announcements.each
    posts = posts.each
    [count, 20].min.times.map do
      announcement_time = announcements.peek.post_time rescue TIME_ZERO
      post_time = posts.peek.post_time rescue TIME_ZERO
      if post_time > announcement_time
        posts.next
      else
        announcements.next
      end
    end
  end

  class AnnouncementRole < SimpleDelegator
    def post_time
      __getobj__.post_time + (time_offset || 0)
    end
  end

end
