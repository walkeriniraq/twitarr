class Post < BaseModel
  attr :message, :post_id, :post_time, :username, :photos

  def post_time
    return @post_time.to_f if @post_time.respond_to? :to_f
    @post_time
  end

end
