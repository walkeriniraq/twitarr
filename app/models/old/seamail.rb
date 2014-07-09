# class Seamail < BaseModel
#   attr :seamail_id, :from, :to, :subject, :text, :sent_time
#
#   def from
#     @from.downcase if @from
#   end
#
#   def sent_time
#     return @sent_time.to_f if @sent_time.respond_to? :to_f
#     @sent_time
#   end
#
#   def to
#     return [ @to.downcase ] if @to.respond_to? :downcase
#     return @to.map { |x| x.downcase } if @to.respond_to? :each
#     @to
#   end
#
# end