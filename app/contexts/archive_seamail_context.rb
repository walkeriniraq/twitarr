class ArchiveSeamailContext
  include HashInitialize

  attr :seamail, :username, :inbox_index, :archive_index

  def call
    @inbox_index.delete @seamail.seamail_id
    @archive_index[@seamail.seamail_id] = @seamail.sent_time
  end

end