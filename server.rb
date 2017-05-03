require 'socket'
require 'json'
require_relative './server_processor'
require_relative './event_loop'
require 'fiber'

# In non-toy implementation these would be configurable
WORKERS = 2
PORT = 8080

# Create server and pre-fork N = WORKERS processes
server = TCPServer.new(PORT)
WORKERS.times do
  fork do
    connections = {}
    connections[server] = Fiber.new do
      loop do
        begin
          socket = server.accept_nonblock
        rescue IO::WaitReadable => e
          Fiber.yield
          retry
        end
        connections[socket] = Fiber.new do |connection|
          server_processor = ServerProcessor.new
          event_loop = EventLoop.new(
            processor: server_processor,
            connection: connection
          )
          event_loop.start
        end
        Fiber.yield
      end
    end
    loop do
      sockets = connections.keys
      r, w, e = IO.select(sockets, sockets, sockets)
      ((r | w) || []).each do |connection|
        fiber = connections[connection]
        if fiber.alive?
          fiber.resume(connection)
        else
          connection.close
          connections.delete(connection)
        end
      end
    end
  end
end

# We forked some processes so we need to wait for them
Process.wait
