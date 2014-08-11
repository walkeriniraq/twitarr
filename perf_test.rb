require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'json'
require 'peach'

requests = [
    Proc.new do |http|
      response = http.request Net::HTTP::Get.new('https://twitarr.rylath.net/posts/all')
      puts "ALL: #{response.msg}"
      data = JSON.parse(response.body)
      photos = data['list'].map { |x| x['data']['photos'] }.flatten.compact!
      photos.each do |photo|
        photo_response = http.request(Net::HTTP::Get.new("https://twitarr.rylath.net/img/photos/sm_#{photo}"))
        puts "PHOTO #{photo}: #{photo_response.msg}"
      end
      1 + photos.size
    end,
    Proc.new do |http|
      response = http.request Net::HTTP::Get.new('https://twitarr.rylath.net/posts/popular')
      puts "POPULAR: #{response.msg}"
      data = JSON.parse(response.body)
      photos = data['list'].map { |x| x['data']['photos'] }.flatten.compact!
      photos.each do |photo|
        photo_response = http.request(Net::HTTP::Get.new("https://twitarr.rylath.net/img/photos/sm_#{photo}"))
        puts "PHOTO #{photo}: #{photo_response.msg}"
      end
      1 + photos.size
    end,
    Proc.new do |http|
      response = http.request Net::HTTP::Get.new('https://twitarr.rylath.net/user/autocomplete?string=g')
      puts "AUTOCOMPLETE: #{response.msg}"
      1
    end,
    Proc.new do |http|
      response = http.request Net::HTTP::Get.new('https://twitarr.rylath.net/api/v1/user/auth?username=kvort&password=foobar')
      puts "AUTH: #{response.msg}"
      1
    end
]

class Array
  def average
    reduce(:+) / size.to_f
  end
end

if __FILE__ == $0

  signal = false
  lock = Mutex.new
  total_count = 0
  start_time = Time.now

  puts 'Starting requests'

  threads = 10.times.map do
    Thread.new do
      count = 0
      while (!signal) do
        Net::HTTP.start('twitarr.rylath.net', 443, :use_ssl => true, :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
          count += requests[Random.rand requests.size].call http
        end
      end
      lock.synchronize { total_count += count }
    end
  end

  trap('INT') do
    puts 'Shutting down'
    signal = true
    threads.each do |thread|
      begin
        thread.join
        puts 'Ended correctly'
      rescue => err
        puts err.inspect
      end
    end
    end_time = Time.now
    puts "TOTAL COUNT: #{total_count} in time: #{end_time - start_time} seconds"
    exit
  end

  sleep
end