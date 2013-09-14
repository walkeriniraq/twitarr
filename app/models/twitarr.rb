class Twitarr

  attr_writer :tag_factory
  attr_reader :popular_posts

  def initialize(args = {})
    @popular_posts = args[:popular_posts] || PopularPosts.new
  end

  def get_tag(tag_name)
    tag_factory.call tag_name
  end

  private

  def tag_factory
    @tag_factory ||= Tag.public_method(:new)
  end

  #attr_writer :post_factory

  #def post_factory
  #  @post_factory ||= Post.public_method(:new)
  #end

  #def create_post(args)
  #  post_factory.call(*args).tap do |p|
  #    p.twitarr = self
  #  end
  #end

  #def add_post(post)
  #  post.save
  #  post.tags.each { |tag| tag.add_post(post) }
  #  post.user.add_post post
  #  popular_posts.add_post post
  #end

end