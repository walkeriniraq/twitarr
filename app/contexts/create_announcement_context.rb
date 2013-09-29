class CreateAnnouncementContext < BaseCreatePostContext

  attr :announcement_index

  def initialize(attrs = {})
    super
    @announcement_index = AnnouncementIndexRole.new(@announcement_index)
  end

  def call
    ret = super
    announcement_index.add_post @post
    ret
  end

  class AnnouncementIndexRole < SimpleDelegator
    def add_post(post)
      self[post.post_id] = post.time_index
    end
  end

end