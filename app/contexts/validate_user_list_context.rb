class ValidateUserListContext
  include HashInitialize

  attr :list, :user_set
  attr_reader :validation

  def initialize(opts = {})
    super
    @validation = []
  end

  def call
    names = list.gsub(/[,@]/, ' ').split
    names.each do |name|
      @validation << name unless user_set.include? name
    end
    return names if @validation.empty?
    nil
  end

end