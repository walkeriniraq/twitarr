class RedisAutocomplete

  def initialize(sorted_set)
    @set = sorted_set
  end

  def add(value, id, uniq)
    @set[{'id' => id, 'uniq' => uniq}.to_json] = RedisAutocomplete.calculate_score(value)
  end

  def query(string)
    list = @set.rangebyscore(
        RedisAutocomplete.calculate_score(string),
        RedisAutocomplete.calculate_next_score(string),
        :limit => 10)
    list.map { |x| JSON.parse(x)['id'] }
  end

  def self.calculate_next_score(string)
    string = string.gsub(/[.,@]/, ' ').split.first.downcase
    score_end = [string.length, INDEX_CHARS].min - 1
    # the hack here is that this could be an invalid character for a name
    # - but it makes the algorithm work
    last_value = string[score_end].ord + 1
    calculate_score(string[0, score_end] + last_value.chr)
  end

  def self.char_value(char)
    case
      when char.nil?
        0
      when char =~ /\d/
        char.ord - NUM_OFFSET
      when char =~ /[a-z]/
        char.ord - CHAR_OFFSET
      else
        0
    end
  end

  def self.calculate_score(string)
    string = string.gsub(/[.,@]/, ' ').split.first.downcase
    count = 0
    sum = 0
    while count <= INDEX_CHARS
      val = char_value string[count]
      sum += val * (37 ** (INDEX_CHARS - count))
      count += 1
    end
    sum
  end

  CHAR_OFFSET = 'a'.ord - 1
  NUM_OFFSET = '0'.ord - 27
  LAST_VALUE = 'z'.ord
  INDEX_CHARS = 5

end