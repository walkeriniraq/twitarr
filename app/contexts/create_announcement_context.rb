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
    include IndexTimeTrait
  end

end