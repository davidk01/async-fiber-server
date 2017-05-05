require_relative './async'
require 'json'

class ClientProcessor

  def start(initial_arguments)
    request = {
      type: :request,
      method: :sum,
      arguments: [1, 2, 3]
    }
    payload = request.to_json
    payload_length = payload.length
    if payload.length > 0xffff
      raise StandardError
    end
    packed_length = [payload_length].pack('n')
    Async.write(packed_length)
    Async.write(payload)
    response_length = Async.read(2) {|buffer| buffer.unpack('n').first}
    response = Async.read(response_length) {|buffer| JSON.parse(buffer)}
    Async.finish
    Async.finished(response)
  end

end
