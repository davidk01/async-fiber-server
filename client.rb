require 'socket'
require_relative './event_loop'
require_relative './client_processor'
require 'fiber'

# Connect to worker pool
s = TCPSocket.new('localhost', 8080)

# The message parser
fiber = Fiber.new do |connection|
  reader = ClientProcessor.new
  event_loop = EventLoop.new(
    processor: reader,
    connection: connection
  )
  event_loop.start
end
response = nil
while fiber.alive?
  response = fiber.resume(s)
  r, w, e = IO.select([s], [s], [s])
end
STDOUT.puts "Client done: #{response.inspect}"
