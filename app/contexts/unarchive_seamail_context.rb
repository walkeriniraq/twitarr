class UnarchiveSeamailContext
  include HashInitialize

  attr :seamail, :username, :inbox_index, :archive_index

  def call
    @inbox_index[@seamail.seamail_id] = @seamail.sent_time
    @archive_index.delete @seamail.seamail_id
  end

end