# module BaseModelInstanceMethods
#
#   def self.included(klass)
#     klass.extend BaseModelClassMethods
#   end
#
#   def to_hash(keys = nil)
#     keys ||= self.class.fattrs
#     keys.reduce({}) do |hash, key|
#       hash[key] = send(key) if send(key)
#       hash
#     end
#   end
#
#   def update(values)
#     values.each do |k, v|
#       if respond_to? k.to_s
#         # this lets us initialize classes with attr_reader
#         instance_variable_set "@#{k.to_s}", v
#       else
#         #TODO: replace this with some sort of logging
#         puts "Invalid parameter passed to class #{self.class.to_s} initialize: #{k.to_s} - value: #{v.to_s}"
#       end
#     end
#   end
#
#   module BaseModelClassMethods
#   end
#
# end
#
# class BaseModel
#   include BaseModelInstanceMethods
#   include HashInitialize
#   include Draper::Decoratable
# end
