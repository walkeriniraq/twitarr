module Searchable
  def self.included(base)
    base.send :include, InstanceMethods
    base.extend ClassMethods
  end

  module InstanceMethods

  end

  module ClassMethods
    DEFAULT_SEARCH_LIMIT = 20
    def limit_criteria(criteria, params)
      limit = (params[:limit] || DEFAULT_SEARCH_LIMIT).to_i
      start = (params[:page] || 0).to_i * limit
      puts "Start = #{start}"
      criteria = criteria.limit(limit)
      criteria = criteria.skip(start) if start > 0
      criteria
    end
  end

end