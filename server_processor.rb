require_relative './async'

class ServerProcessor

  def start(initial_arguments)
    message_length = Async.read(2) {|buffer| buffer.unpack('n').first}
    payload = Async.read(message_length) {|buffer| JSON.parse(buffer)}
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
