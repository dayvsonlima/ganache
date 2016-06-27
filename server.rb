require 'socket' # Provides TCPServer and TCPSocket classes
require 'pp'
# Initialize a TCPServer object that will listen
# on localhost:2345 for incoming connections.
server = TCPServer.new('127.0.0.1', 2345)

# loop infinitely, processing one incoming
# connection at a time.
loop do

  # Wait until a client connects, then return a TCPSocket
  # that can be used in a similar fashion to other Ruby
  # I/O objects. (In fact, TCPSocket is a subclass of IO.)
  socket = server.accept

  # Read the first line of the request (the Request-Line)
  request = socket.gets

  # Log the request to the console for debugging
  STDERR.puts request
  

  path = socket.gets.split                    # In this case, method = "POST" and path = "/"
  headers = {}
  while line = socket.gets.split(' ', 2)              # Collect HTTP headers
    break if line[0] == ""                            # Blank line means no more headers
    headers[line[0].chop] = line[1].strip             # Hash headers by type
  end
  data = socket.read(headers["Content-Length"].to_i)  # Read the POST data as specified in the header

  $_POST = {}

  data = data.split('&').map{|p| Hash[*p.split('=')] rescue nil }

  data.each do |d|
    $_POST.merge!(d)
  end

  pp $_POST


  response = "lorem ipsun dolor sit ammet <form method='post'><input name='okok' /><input name='outro' /><input type='submit' /></form>"

  # We need to include the Content-Type and Content-Length headers
  # to let the client know the size and type of data
  # contained in the response. Note that HTTP is whitespace
  # sensitive, and expects each header line to end with CRLF (i.e. "\r\n")
  socket.print "HTTP/1.1 200 OK\r\n" +
               # "Content-Type: text/plain\r\n" +
               "Content-Type:text/html; charset=utf-8\r\n" + 
               "Content-Length: #{response.bytesize}\r\n" +
               "Connection: close\r\n"

  # Print a blank line to separate the header from the response body,
  # as required by the protocol.
  socket.print "\r\n"

  # Print the actual response body, which is just "Hello World!\n"
  socket.print response

  # Close the socket, terminating the connection
  socket.close

end
