class RedisAutocomplete

  def initialize(sorted_set)
    @set = sorted_set
  end

  def add(value, id, uniq)
    val = {'id' => id, 'uniq' => uniq}.to_json
    return if @set.member?(val)
    @set[val] = RedisAutocomplete.calculate_score(value)
  end

  def query(string)
    string = string.gsub(/[.,@]/, ' ').split.first
    return [] if string.blank?
    list = @set.rangebyscore(
        RedisAutocomplete.calculate_score(string),
        RedisAutocomplete.calculate_next_score(string),
        :limit => 10)
    list.map { |x| JSON.parse(x)['id'] }
  end

  def self.calculate_next_score(string)
    score = calculate_score(string)
    score + CARDINALITY ** (INDEX_CHARS - [string.length, INDEX_CHARS].min)
  end

  def self.char_value(char)
    case
      when char.nil?
        0
      when char =~ /\d/
        char.ord - NUM_OFFSET
      when char =~ /[a-z]/
        char.ord - CHAR_OFFSET
      when char == '_'
        37
      when char == '-'
        38
      when char == '&'
        39
      else
        0
    end
  end

  def self.calculate_score(string)
    string = string.gsub(/[.,@]/, ' ').split.first.downcase
    count = 0
    sum = 0
    while count < INDEX_CHARS
      val = char_value string[count]
      sum += val * (CARDINALITY ** (INDEX_CHARS - count - 1))
      count += 1
    end
    sum
  end

  CHAR_OFFSET = 'a'.ord - 1
  NUM_OFFSET = '0'.ord - 27
  INDEX_CHARS = 10
  CARDINALITY = 40

end