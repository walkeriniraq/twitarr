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
  field :fa, as: :favorites, type: Array, default: []
  field :of, as: :official, type: Boolean
  field :sh, as: :shared, type: Boolean, default: true

  validates :title, :start_time, presence: true
  #validates :title, uniqueness: true

  validates_presence_of :author, unless: "official" # Official events won't have owners.

  # 1 = ASC, -1 DESC
  index start_time: -1
  index author: 1
  index title: 1
  index({:title => 'text', :description => 'text'})

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
    event.shared = options[:shared] unless options[:shared].nil?
    # Time.parse should occur on the controller side, but I haven't got time to straighten this out right now
    event.end_time = Time.parse(options[:end_time]) unless options[:end_time].nil?
    event.max_signups = options[:max_signups] unless options[:max_signups].nil?
    event
  end

end
