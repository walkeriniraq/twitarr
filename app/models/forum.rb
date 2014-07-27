class Forum
  include Mongoid::Document

  field :au, as: :author, type: String
  field :sj, as: :subject, type: String
  field :lp, as: :last_post, type: Time

  has_many :forum_posts

end