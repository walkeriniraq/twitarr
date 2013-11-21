class Stats

  attr_reader :db

  def initialize(redis)
    @db = redis
  end

  def log_event(type, user)
    stats = @db.redis_hash "System:stats_overall"
    date = Time.now
    stats.incr('activity')
    stats.incr("activity:#{type}")
    hourly_stats = @db.redis_hash "System:stats_hourly:#{date.strftime '%Y-%m-%d-%H'}"
    hourly_stats.incr('activity')
    hourly_stats.incr("activity:#{type}")
    @db.list("System:log").unshift("#{date.strftime '%Y%m%d-%H:%M:%S'} #{type} #{user}")
  end

  def overall_stats
    @db.hash("System:stats_overall").all
  end

end