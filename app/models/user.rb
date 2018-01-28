require 'bcrypt'

class User
  include Mongoid::Document
  include Searchable

  USERNAME_CACHE_TIME = 30.minutes

  USERNAME_REGEX = /^[\w&-]{3,}$/
  DISPLAY_NAME_REGEX = /^[\w\. &-]{3,40}$/

  ACTIVE_STATUS = 'active'
  RESET_PASSWORD = 'seamonkey'

  field :un, as: :username, type: String
  field :pw, as: :password, type: String
  field :ia, as: :is_admin, type: Boolean
  field :st, as: :status, type: String
  field :em, as: :email, type: String
  field :dn, as: :display_name, type: String
  field :ll, as: :last_login, type: DateTime
  field :sq, as: :security_question, type: String
  field :sa, as: :security_answer, type: String
  field :um, as: :unnoticed_mentions, type: Integer, default: 0
  field :al, as: :last_viewed_alerts, type: DateTime, default: Time.at(0)
  field :ph, as: :photo_hash, type: String
  field :pu, as: :last_photo_updated, type: Integer, default: Time.now.to_i
  field :rn, as: :room_number, type: String
  field :pe, as: :is_email_public, type: Boolean
  field :an, as: :real_name, type: String
  field :hl, as: :home_location, type: String
  field :lf, as: :forum_view_timestamps, type: Hash, default: {}
  field :pv, as: :is_vcard_public, type: Boolean, default: true
  field :lc, as: :current_location, type: String
  field :us, as: :starred_users, type: Array, default: []
  field :pc, as: :personal_comments, type: Hash, default: {}
  field :ea, as: :acknowledged_event_alerts, type: Array, default: []

  index username: 1
  index display_name: 1
  index :display_name => 'text'

  # noinspection RubyResolve
  after_save :update_display_name_cache

  validate :valid_username?
  validate :valid_display_name?
  validate :valid_location?
  validates :email, format: { with: /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i, message: 'address is not valid.' }
  validates :security_question, :security_answer, presence: true
  
  def self.valid_username?(username)
    return false unless username
    !username.match(USERNAME_REGEX).nil?
  end

  def valid_username?
    unless User.valid_username? (username)
      errors.add(:username, 'must be three or more characters and only include letters, numbers, underscore, dash, and ampersand')
    end
  end

  def self.valid_display_name?(name)
    return true unless name
    !name.match(DISPLAY_NAME_REGEX).nil?
  end

  def valid_display_name?
    unless User.valid_display_name? (display_name)
      errors.add(:display_name, 'must be three or more characters and cannot include any of ~!@#$%^*()+=<>{}[]\\|;:/?')
    end
  end

  def valid_location?
    user_location = self[:current_location]
    Location.valid_location? user_location
  end

  def empty_password?
    password.nil? || password.empty?
  end

  def set_password(pass)
    self.password = BCrypt::Password.create pass
  end

  def correct_password(pass)
    BCrypt::Password.new(password) == pass
  end

  def update_last_login
    self.last_login = Time.now.to_f
    self
  end

  def email_public?
    self[:is_email_public]
  end

  def email_public=(val)
    self[:is_email_public] = !val.nil? && val.to_bool
  end


  def username=(val)
    super User.format_username val
  end

  def current_location=(loc)
    super loc
  end

  def security_answer=(val)
    super val.andand.downcase.andand.strip
  end

  def security_question=(val)
    super val.andand.strip
  end

  def display_name=(val)
    super val.andand.strip
  end

  def room_number=(val)
    if val.is_a? Numeric
      return super val
    else
      return super val.andand.strip.to_i
    end
  end

  def real_name=(val)
    super val.andand.strip
  end

  def home_location=(val)
    super val.andand.strip
  end

  def vcard_public?
    self[:is_vcard_public]
  end

  def vcard_public=(val)
    self[:is_vcard_public] = !val.nil? && val.to_bool
  end

  def upcoming_events(alerts=false)
    events = Event.where(:start_time.gte => (DateTime.now - 1.hours)).where(:start_time.lte => (DateTime.now + 3.hours)).limit(20).order_by(:start_time.desc)
    events = events.map {|x| x if !x.end_time or x.end_time > DateTime.now }.compact
    events = events.map { |x| x if x.favorites.include? self.username }.compact
    if alerts
      events = events.map { |e| e unless self.acknowledged_event_alerts.include? e.id }.compact
      events.each { |e| self.acknowledged_event_alerts << e.id unless self.acknowledged_event_alerts.include? e.id }
      self.save
    end
    events
  end

  def unnoticed_upcoming_events
    events = self.upcoming_events()
    events = events.map {|e| e unless self.acknowledged_event_alerts.include? e.id}.compact
    events.count
  end

  def seamails(params = {})
    query = {usernames: username}
    query[:unread_users] = username if params.has_key?(:unread)
    query[:last_update.gte] = params[:after] if params.has_key?(:after)
    Seamail.where(query).sort_by { |x| x.last_message }.reverse
  end

  def seamail_unread_count
    Seamail.where(usernames: username, unread_users: username).length
  end


  def seamail_count
    Seamail.where(usernames: username).length
  end

  def liked_posts
    ForumPost.where(:likes.in => [self.username]).union(StreamPost.where(:likes.in => [self.username])).order_by(timestamp: :desc)
  end


  def number_of_tweets
    StreamPost.where(author: self.username).count
  end

  def number_of_mentions
    StreamPost.where(mentions: self.username).count
  end

  def self.format_username(username)
    username.andand.downcase.andand.strip
  end

  def self.exist?(username)
    where(username: format_username(username)).exists?
  end

  def self.get(username)
    where(username: format_username(username)).first
  end

  def reset_photo
    result = PhotoStore.instance.reset_profile_photo username
    if result[:status] == 'ok'
      self.photo_hash = result[:md5_hash]
      self.last_photo_updated = Time.now.to_i
      save
    end
    result
  end

  def update_photo(file)
    result = PhotoStore.instance.upload_profile_photo(file, username)
    if result[:status] == 'ok'
      self.photo_hash = result[:md5_hash]
      self.last_photo_updated = Time.now.to_i
      save
    end
    result
  end

  def profile_picture_path
    path = PhotoStore.instance.small_profile_path(username)
    reset_photo unless File.exists? path
    path
  end

  def full_profile_picture_path
    path = PhotoStore.instance.full_profile_path(username)
    reset_photo unless File.exists? path
    path
  end

  def inc_mentions
    inc(unnoticed_mentions: 1)
  end

  def self.inc_mentions(username)
    User.find_by(username: username).inc(unnoticed_mentions: 1)
  end

  def reset_mentions
    set(unnoticed_mentions: 0)
  end

  def update_forum_view(forum_id)
    self.forum_view_timestamps[forum_id] = Time.now
    save
  end

  def reset_last_viewed_alerts
    reset_mentions
    self.last_viewed_alerts = DateTime.now
  end

  def unnoticed_announcements
    Announcement.new_announcements(last_viewed_alerts).count
  end

  def unnoticed_alerts
    (unnoticed_mentions || 0) > 0 || (seamail_unread_count || 0) > 0 || unnoticed_announcements >= 1 || unnoticed_upcoming_events >= 1
  end

  def self.display_name_from_username(username)
    Rails.cache.fetch("display_name:#{username}", expires_in: USERNAME_CACHE_TIME) do
      User.where(username: username).only(:display_name).map(:display_name).first
    end
  end

  def self.last_photo_updated_from_username(username)
    Rails.cache.fetch("last_photo_updated:#{username}", expires_in: 5.minutes) do
      User.where(username: username).only(:last_photo_updated).map(:last_photo_updated).first
    end
  end

  def update_display_name_cache
    Rails.cache.fetch("display_name:#{username}", force: true, expires_in: USERNAME_CACHE_TIME ) do
      display_name
    end
  end

  def last_forum_view(forum_id)
    self.forum_view_timestamps[forum_id] || Time.new(0)
  end

  def self.search(params = {})
    query = params[:text].gsub(/\W/,'')
    criteria = User.or({username: Regexp.new(query)}, { '$text' => { '$search' => "\"#{query}\"" } })
    limit_criteria(criteria, params)
  end
end
