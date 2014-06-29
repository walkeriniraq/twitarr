# class NamedSetCache
#   def initialize(factory)
#     @factory = factory
#     @cache = {}
#   end
#
#   def [](name)
#     unless @cache.has_key? name
#       @cache[name] = @factory.call name
#     end
#     @cache[name]
#   end
#
# end