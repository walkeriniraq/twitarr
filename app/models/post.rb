class Post < BaseModel
  attr :message, :post_id, :post_time, :username

  def initialize(hash = {})
    super
    @post_time = @post_time.to_f
  end

end
