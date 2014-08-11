# class ArchiveSeamailContext
#   include HashInitialize
#
#   attr :seamail, :username, :inbox_index, :archive_index
#
#   def call
#     @archive_index[@seamail.seamail_id] = @seamail.sent_time
#     @inbox_index.delete @seamail.seamail_id
#   end
#
# end