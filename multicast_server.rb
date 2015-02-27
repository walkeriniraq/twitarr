require 'socket'
require 'ipaddr'
require 'thread'

class String
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m" 
  end

  def red
    colorize(91)
  end

  def green
    colorize(92)
  end

  def yellow
    colorize(93)
  end

  def cyan
    colorize(96)
  end
end

class Server
  CAST_ADDR = "224.0.0.1"
  BIND = "0.0.0.0"
  PORT = 30512

  attr_reader :ip_addr
  def initialize(ip)
    @ip_addr = ip
  end

  def listen
    socket.bind(BIND, PORT)
    puts "Startup! Replying with IP #{ip_addr}".green
    loop do
      begin
        data, clientAddr = socket.recvfrom(150)
        Thread.start(data,clientAddr) do |data,clientAddr|
          # We don't want to reply to ourselves
          if data[0..3] != "ack," and data.length == 32
            puts "New message from #{clientAddr[3]}".cyan
            message = Response.new(data, ip_addr)
            puts "Responding".yellow
            socket.send(message.to_csv, 0, CAST_ADDR, PORT)
          end
        end
      rescue Errno::EMSGSIZE,Errno::ENOBUFS => e
        puts "Error with recieved packet: #{e.message}".red
      end
    end
  end
  private 

  def socket
    @socket ||= UDPSocket.open.tap do |socket|
      socket.setsockopt(Socket::IPPROTO_IP, Socket::IP_ADD_MEMBERSHIP, bind_hton)
      socket.setsockopt(Socket::IPPROTO_IP, Socket::IP_MULTICAST_TTL, 1)
      socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1)
    end
  end

  def bind_hton
    IPAddr.new(CAST_ADDR).hton + IPAddr.new(BIND).hton
  end
end

class Response

  #
  # Responses are CSV formatted plaintext. They are multicasted back and
  # are structured as so: "ack,[User Unique ID],[Twitarr Address]"
  #

  attr_reader :uuid, :address
  def initialize(uuid, ip)
    @uuid = uuid
    @address = ip
  end

  def to_a
    ["ack", uuid, address]
  end

  def to_csv
    self.to_a.join(",")
  end
end
# This is messy and sucks.
# The IP the server will reply with for twitarr, we can enter anything on this. Even a DNS uri! It's just a string.
ip = ARGV[0] || Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address # Woo, stackoverflow!
Server.new(ip).listen