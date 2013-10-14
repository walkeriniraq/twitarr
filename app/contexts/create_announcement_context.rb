class CreateAnnouncementContext
  include HashInitialize

  attr :list

  def call(username, text, time_offset)
    announcement = Announcement.new message: text, username: username, post_id: SecureRandom.uuid, post_time: Time.now, time_offset: time_offset
    list.unshift announcement
  end

end