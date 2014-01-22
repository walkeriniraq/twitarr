class BaseRedisController < ActionController::Base

  around_action :redis_context_filter

  def redis_context_filter
    DbConnectionPool.instance.connection do |redis|
      @redis_connection = redis
      yield
      @redis_connection = nil  # While this shouldn't be neccesary, it's best to make sure
    end
  end

  def redis
    @redis_connection
  end

  def login_required
    render json: { status: 'Not logged in.' }
  end

  def render_json(hash)
    render json: hash
  end

  def get_username(key)
    key.split(':').first
  end

  def valid_key?(key)
    return false if key.nil?
    return false unless key.include? ':'
    username = get_username key
    CHECK_DAYS_BACK.times do |x|
      return true if build_key(username, x) == key
    end
    false
  end

  def build_key(name, days_back = 0)
    digest = OpenSSL::HMAC.hexdigest(
        OpenSSL::Digest::SHA1.new,
        Twitarr::Application.config.secret_key_base,
        "#{name}#{Time.now.year}#{Time.now.yday - days_back}"
    )
    "#{name}:#{digest}"
  end

  CHECK_DAYS_BACK = 10

end