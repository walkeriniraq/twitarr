class Event
  include Mongoid::Document
  include Searchable

  field :au, as: :author, type: String
  field :tl, as: :title, type: String
  field :sm, as: :description, type: String
  field :lc, as: :location, type: String # Should do some auto-suggest magic with this?
  field :st, as: :start_time, type: Time
  field :et, as: :end_time, type: Time
  field :ms, as: :max_signups, type: Integer
  field :su, as: :signups, type: Array, default: []
  field :of, as: :official, type: Boolean

  validates :title, :author, :start_time, :location, presence: true
  validates :title, uniqueness: true

  # 1 = ASC, -1 DESC
  index at_time: -1
  index author: 1

  def self.search(params = {})
    # TODO
  end

  def self.create_new_event(author, title, start_time, location, options={})
    event = Event.new(author: author, title: title, start_time: start_time, location: location)
    event.description = options[:description] unless options[:description].nil?
    event.end_time = options[:end_time] unless options[:end_time].nil?
    event.max_signups = options[:max_signups] unless options[:max_signups].nil?
    event.save if event.valid?
    event
  end

end