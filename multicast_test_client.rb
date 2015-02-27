require 'socket'
require 'ipaddr'
require 'thread'
require 'csv'
require 'securerandom'

class ResponseServer
  BIND = "0.0.0.0"
  PORT = 30512

  attr_reader :listening

  def initialize
    @listening = false
  end

  def listen
    socket.bind(BIND, PORT)
    puts "Listening for reply."
    @listening = true
    loop do
      begin
        data, clientAddr = socket.recvfrom(150)
        puts "Message recieved..."
        Thread.start(data,clientAddr) do |data,clientAddr|
          # We only really want to work on replies. 
          # You could make it strict as to only recognise a response with the correct UUID but for the purposes of this test...
          if data[0..3] == "ack,"
            csv = CSV.new(data).read.flatten # CSV Lib, you're fucking WEIRD.
            puts "Twitarr is hosted on #{csv[2]}"
            exit
          else
            puts "Invalid message: #{data}"
          end
        end
      rescue Errno::EMSGSIZE,Errno::ENOBUFS => e
        puts "Error with recieved packet: #{e.message}"
      end
      break unless listening
    end
  end
  private 

  def socket
    @socket ||= UDPSocket.open.tap do |socket|
      # All permissions for listening for multicast.
      socket.setsockopt(Socket::IPPROTO_IP, Socket::IP_ADD_MEMBERSHIP, bind_hton)
      socket.setsockopt(Socket::IPPROTO_IP, Socket::IP_MULTICAST_TTL, 1)
      socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1)
    end
  end

  def bind_hton
    IPAddr.new(CAST_ADDR).hton + IPAddr.new(BIND).hton
  end

end

# This is ugly. I know. But it works.
port = 30512
CAST_ADDR = "224.0.0.1"

sendSocket = UDPSocket.open
# Get multicast permission
sendSocket.setsockopt(:IPPROTO_IP, :IP_MULTICAST_TTL, 1)
# Generate unique UUID. Not TOO important, but it MUST be 32 characters long.
uuid = SecureRandom.hex(16)
puts "Sending message..."
# Multicast our request off
sendSocket.send(uuid, 0, CAST_ADDR, port)
# Start listening for a reply.
ResponseServer.new.listen
# In a good implementation, there would be a timeout and retry