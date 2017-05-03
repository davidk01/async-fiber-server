class Event

  Events = [
    Initialize = :initialize,
    Read = :read,
    Write = :write,
    Finish = :finish,
    Finished = :finished,
    Start = :start,
    Wait = :wait,
    Waited = :waited
  ]

  attr_reader :type, :payload

  def initialize(event, payload)
    unless Events.include?(event)
      raise StandardError, "Unknown event: #{event}"
    end
    @type, @payload = event, payload
  end

  def self.[](event, payload = nil)
    new(event, payload)
  end

end
