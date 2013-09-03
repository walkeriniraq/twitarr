class Twitarr

  attr_writer :post_factory
  attr_reader :popular_posts

  def initialize(args = {})
    @popular_posts = args[:popular_posts] || PopularPosts.new
  end

  def create_post(args)
    post_factory.call(*args).tap do |p|
      p.twitarr = self
    end
  end

  def user_exist?(username)

  end

  def add_post(post)
    post.save
    post.tags.each { |tag| tag.add_post(post) }
    post.user.add_post post
    popular_posts.add_post post
  end

  private

  def post_factory
    @post_factory ||= Post.public_method(:new)
  end

end