# class RedisObjectIndex
#
#   attr_reader :db, :fields_to_index, :clazz
#
#   def initialize(redis, obj_clazz, obj_fields_to_index)
#     @db = redis
#     @clazz = obj_clazz
#     @fields_to_index = obj_fields_to_index
#   end
#
#   def sort_list(redis_list, sort_field, options = {})
#     sort_options = {:by => "#{clazz.to_s}:index|*->#{sort_field}"}
#     sort_options[:order] = options[:order] if options.has_key? :order
#     sort_options[:limit] = options[:limit] if options.has_key? :limit
#     sort_options[:store] = options[:store] if options.has_key? :store
#     redis_list.sort(sort_options)
#   end
#
#   def index(obj, id)
#     obj_key = "#{obj.class.to_s}:index|#{id}"
#     db.multi do
#       fields_to_index.each { |field|
#         db.hset obj_key, field, obj.send(field)
#       }
#     end
#   end
#
#   def delete(id)
#       db.del "#{clazz.to_s}:index|#{id}"
#   end
# end