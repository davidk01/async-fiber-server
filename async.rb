require_relative './event'

module Async

  def self.read(count, &blk)
    buffer, to_read = "", count
    while to_read > 0
      response = Fiber.yield(Event[Event::Read, to_read])
      buffer += response.payload
      to_read -= buffer.length
    end
    blk.nil? ? buffer : blk.call(buffer)
  end

  def self.write(content)
    while content.length > 0
      written = Fiber.yield(Event[Event::Write, content])
      written_length = written.payload
      content = content[written_length..-1]
    end
  end

  def self.finish
    Fiber.yield(Event[Event::Finish])
  end

  def self.finished(ret)
    Fiber.yield(Event[Event::Finished, ret])
  end

end
