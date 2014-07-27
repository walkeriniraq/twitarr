class StreamPost
  include Mongoid::Document

  field :au, as: :author, type: String
  field :tx, as: :text, type: String
  field :ts, as: :timestamp, type: Time

  def self.at_or_before(ms_since_epoch)
    where(:timestamp.lte => Time.at(ms_since_epoch.to_i / 1000))
  end

end