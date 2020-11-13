import asyncnet, asyncdispatch
import nativesockets

var clients {.threadvar.}: seq[AsyncSocket]

type
  InboundHander = proc (client: AsyncSocket) {.async.}

  TCPServer* = object
    socket: AsyncSocket
    inbound_handler: InboundHander

  TCPROSServer = object
    server: TCPServer

  TCPROSHandler* = object
    tcp_ros_server: TCPROSServer


## TCPSerer
proc newTCPServer*(inbound_handler: InboundHander): TCPServer =
  let socket = newAsyncSocket()
  socket.setSockOpt(OptReuseAddr, true)
  socket.bindAddr()
  socket.listen()

  result = TCPServer(socket: socket,
                     inbound_handler: inbound_handler)

proc getFullAddr*(tcp_server: TCPServer) : (string, Port) =
  result = tcp_server.socket.getLocalAddr()


proc start(tcp_server: TCPServer) {.async.} =
  clients = @[]
  while true:
    let client = await tcp_server.socket.accept()
    clients.add(client)

    asyncCheck tcp_server.inbound_handler(client)

proc shutdown(tcp_server: TCPServer) =
  if not tcp_server.socket.isClosed():
    tcp_server.socket.close()


proc processClient(client: AsyncSocket) {.async.} =
  while true:
    let line = await client.recvLine()
    if line.len == 0: break
    for c in clients:
      await c.send(line & "\c\L")


## TCPROSServer
proc newTCPROSServer*(): TCPROSServer =
  result = TCPROSServer(server: newTCPServer(inbound_handler=processClient))

proc startServer*(tcp_ros_server: TCPROSServer) {.async.} =
  asyncCheck tcp_ros_server.server.start()

proc getAddress*(tcp_ros_server: TCPROSServer): (string, Port) =
  result = tcp_ros_server.server.getFullAddr()

proc shutdown*(tcp_ros_server: TCPROSServer) =
  tcp_ros_server.server.shutdown()

## TCPROSHandler
proc newTCPROSHandler*(): TCPROSHandler =
  result = TCPROSHandler(tcp_ros_server: newTCPROSServer())

# proc createTransport(tcp_ros_handler: TCPROSHandler) =
#   discard

# proc initPublisher(tcp_ros_handler: TCPROSHandler) =
#   # asyncCheck tcp_ros_handler.tcp_ros_server.startServer()
#   discard

# proc topicConnectionHandler(tcp_ros_handler: TCPROSHandler) =
#   discard
