class Seamail
  include Mongoid::Document

  field :us, as: :users, type: Array
  field :sj, as: :subject, type: String
  field :lm, as: :last_message, type: Time

  has_many :seamail_messages, :order => :timestamp.desc

end