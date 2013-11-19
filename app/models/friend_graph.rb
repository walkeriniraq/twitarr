class FriendGraph

  def initialize(following_relations, followed_relations)
    @following_relations = following_relations
    @followed_relations = followed_relations
  end

  def add(from, to)
    from = from.downcase
    to = to.downcase
    @following_relations[from] << to
    @followed_relations[to] << from
  end

  def remove(from, to)
    from = from.downcase
    to = to.downcase
    @following_relations[from].delete to
    @followed_relations[to].delete from
  end

  def followed(name)
    name = name.downcase
    @followed_relations[name]
  end

end