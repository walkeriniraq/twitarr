class SeamailMessage
  include Mongoid::Document

  field :au, as: :author, type: String
  field :tx, as: :text, type: String
  field :ts, as: :timestamp, type: Time

  belongs_to :seamail

  validates :text, presence: true

end