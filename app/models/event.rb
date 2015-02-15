class Event
  include Mongoid::Document
  include Searchable

  field :au, as: :author, type: String
  field :tl, as: :title, type: String
  field :lc, as: :location, type: String # Should do some auto-suggest magic with this?
  field :at, as: :at_time, type: Time
  field :ms, as: :max_signups, type: Integer
  field :su, as: :signups, type: Array, default: []

  validates :title, :author, :at_time, :location, presence: true

  # 1 = ASC, -1 DESC
  index at_time: -1
  index author: 1

  def self.search(params = {})
    # TODO
  end

end