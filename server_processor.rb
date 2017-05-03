require_relative './async'

class ServerProcessor

  def start(initial_arguments)
    buffer = Async.read(2)
    message_length = buffer.unpack('n').first
    buffer = Async.read(message_length)
    payload = JSON.parse(buffer)
    server_response = {
      type: :response,
      response: 6
    }.to_json
    response_length = [server_response.length].pack('n')
    Async.write(response_length)
    Async.write(server_response)
    Async.finish
    Async.finished(nil)
  end

end
