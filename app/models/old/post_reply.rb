# class PostReply < BaseModel
#   attr :username, :message, :timestamp
#
#   def timestamp
#     return @timestamp.to_f if @timestamp.respond_to? :to_f
#     @timestamp
#   end
#
# end