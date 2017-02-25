class Event
  include Mongoid::Document
  include Searchable

  field :tl, as: :title, type: String
  field :sm, as: :description, type: String
  field :lc, as: :location, type: String
  field :st, as: :start_time, type: Time
  field :et, as: :end_time, type: Time
  field :fa, as: :favorites, type: Array, default: []
  # TODO add type
  field :of, as: :official, type: Boolean

  validates :title, :start_time, presence: true

  # 1 = ASC, -1 DESC
  index start_time: -1
  index({:title => 'text', :description => 'text', :location => 'text'})

  def self.search(params = {})
    search_text = params[:text].strip.downcase.gsub(/[^0-9A-Za-z_\s@]/, '')
    criteria = Event.or({ title: /^#{search_text}/ }, { '$text' => { '$search' => "\"#{search_text}\"" } })
    limit_criteria(criteria, params).order_by(timestamp: :desc)
  end

  def self.create_new_event(author, title, start_time, options={})
    event = Event.new(author: author, title: title, start_time: start_time)
    event.description = options[:description] unless options[:description].nil?
    event.location = options[:location] unless options[:location].nil?
    event.official = options[:official] unless options[:official].nil?
    # Time.parse should occur on the controller side, but I haven't got time to straighten this out right now
    event.end_time = Time.parse(options[:end_time]) unless options[:end_time].nil?
    event
  end

  def self.create_from_ics(event)
    Event.new(
        _id: event.uid,
        title: event.summary,
        description: event.description,
        start_time: event.dtstart,
        end_time: event.dtend,
        official: !event.categories.include?('SHADOW CRUISE'),
        location: event.location
    ).upsert
  end

  def follow(username)
    self.favorites << username unless self.favorites.include? username
  end

  def unfollow(username)
    self.favorites.delete username
  end

end
