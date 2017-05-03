require_relative './event'

class EventLoop

  attr_reader :processor, :connection

  def initialize(processor:, connection:)
    @processor, @connection = Fiber.new {|resp| processor.start(resp) }, connection
  end

  def start
    response = Event[Event::Start]
    begin
      event = processor.resume(response)
      type, payload = event.type, event.payload
      case type
      when Event::Wait
        duration = payload
        sleep duration
        response = Event[Event::Waited, duration]
      when Event::Finish
        response = Event[Event::Finished, true]
      when Event::Finished
        return event
      when Event::Read
        begin
          count = payload
          read = connection.read_nonblock(count)
          response = Event[Event::Read, read]
        rescue IO::WaitReadable
          Fiber.yield
          retry
        end
      when Event::Write
        begin
          content = payload
          written = connection.write_nonblock(content)
          response = Event[Event::Write, written]
        rescue IO::WaitWritable
          Fiber.yield
          retry
        end
      else
        raise StandardError, "Unknown event: #{type}"
      end
    rescue IOError => e
      break
    end while true
  end

end
