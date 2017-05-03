# Description
Toy evented Ruby server and client using fibers to make event management simpler.

# Usage
To see the server and client interaction start the server (`ruby server.rb`)
and then run the client (`ruby client.rb`). The results are printed to standard output stream.

# Overview
Client logic is implemented in `client_processor.b` and the server logic is
is implemented in `server_processor.rb`. Both client and server use `event_loop.rb`
for the event management. The event management really being about asynchronous
requests to read and write from the connected socket with the help of `Async` (`async.rb`)
module. The `Async` module provides a simple API over the events defined in
`event.rb`

The connection handling loop for the server is implemented in `server.rb`. It is
a simple pre-forking server with a fiber loop.
