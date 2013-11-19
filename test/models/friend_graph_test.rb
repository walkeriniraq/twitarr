require 'test_helper'

class FriendGraphTest < ActiveSupport::TestCase
  subject { FriendGraph }

  def test_add_adds_from_side
    following_cache = NamedSetCache.new(lambda { |name| Set.new })
    followed_cache = NamedSetCache.new(lambda { |name| Set.new })
    graph = FriendGraph.new(following_cache, followed_cache)
    graph.add('steve', 'dave')
    following_cache['steve'].must_include 'dave'
  end

  def test_add_adds_to_side
    following_cache = NamedSetCache.new(lambda { |name| Set.new })
    followed_cache = NamedSetCache.new(lambda { |name| Set.new })
    graph = FriendGraph.new(following_cache, followed_cache)
    graph.add('steve', 'dave')
    followed_cache['dave'].must_include 'steve'
  end

  def test_add_lowercases_names
    following_cache = NamedSetCache.new(lambda { |name| Set.new })
    followed_cache = NamedSetCache.new(lambda { |name| Set.new })
    graph = FriendGraph.new(following_cache, followed_cache)
    graph.add('STEVE', 'DAVE')
    following_cache['steve'].must_include 'dave'
  end

  def test_remove_removes_from_side
    following_cache = NamedSetCache.new(lambda { |name| Set.new(['dave']) })
    followed_cache = NamedSetCache.new(lambda { |name| Set.new(['steve']) })
    graph = FriendGraph.new(following_cache, followed_cache)
    graph.remove('steve', 'dave')
    following_cache['steve'].wont_include 'dave'
  end

  def test_remove_removes_to_side
    following_cache = NamedSetCache.new(lambda { |name| Set.new(['dave']) })
    followed_cache = NamedSetCache.new(lambda { |name| Set.new(['steve']) })
    graph = FriendGraph.new(following_cache, followed_cache)
    graph.remove('steve', 'dave')
    followed_cache['dave'].wont_include 'steve'
  end

  def test_remove_lowercases_names
    following_cache = NamedSetCache.new(lambda { |name| Set.new(['dave']) })
    followed_cache = NamedSetCache.new(lambda { |name| Set.new(['steve']) })
    graph = FriendGraph.new(following_cache, followed_cache)
    graph.remove('STEVE', 'DAVE')
    following_cache['steve'].wont_include 'dave'
  end

  def test_followed_lowercases_names
    stored_name = ''
    following_cache = NamedSetCache.new(lambda { |name| Set.new(['dave']) })
    followed_cache = NamedSetCache.new(lambda do |name|
      stored_name = name
      Set.new(['steve'])
    end)
    graph = FriendGraph.new(following_cache, followed_cache)
    graph.followed('DAVE').must_include 'steve'
    stored_name.must_equal 'dave'
  end

end