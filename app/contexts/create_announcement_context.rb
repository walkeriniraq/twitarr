class CreateAnnouncementContext
  include HashInitialize

  attr :set

  def call(username, text, time_offset)
    announcement = Announcement.new(
        message: text,
        username: username,
        post_id: SecureRandom.uuid,
        post_time: Time.now.to_f,
        time_offset: time_offset
    )
    set.save announcement, announcement.time_plus_offset
  end

end