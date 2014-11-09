class PhotoMetadata
  include Mongoid::Document

  field :up, as: :uploader, type: String
  field :ofn, as: :original_filename, type: String
  field :fn, as: :store_filename, type: String
  field :ut, as: :upload_time, type: Time
  field :hsh, as: :md5_hash, type: String

  def serializable_hash(options)
    original_hash = super(options)
    Hash[original_hash.map {|k, v|
           [self.aliased_fields.invert[k] || k , as_str(v)]
         }]
  end

  def as_str(v)
    return v.to_str if v.is_a? BSON::ObjectId
    v
  end
end