module HashInitialize
  def initialize(opts = {})
    initialize_values(opts)
  end

  def initialize_values(opts)
    opts.each do |k, v|
      if respond_to? k.to_s
        # this lets us initialize classes with attr_reader
        instance_variable_set "@#{k.to_s}", v
      else
        #9 - replace this with some sort of logging
        puts "Invalid parameter passed to class #{self.class.to_s} initialize: #{k.to_s} - value: #{v.to_s}"
      end
    end
  end
end