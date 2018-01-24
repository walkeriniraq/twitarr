class SeamailMessage
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  field :au, as: :author, type: String
  field :tx, as: :text, type: String
  field :ts, as: :timestamp, type: Time
  embedded_in :seamail, inverse_of: :messages

  validates :text, :author, :timestamp, presence: true
  validate :validate_author

  def validate_author
    return if author.blank?
    unless User.exist? author
      errors[:base] << "#{author} is not a valid username"
    end
  end

  def author=(username)
    super User.format_username username
  end

end
