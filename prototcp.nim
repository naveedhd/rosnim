import net


type
  Server* = object
    socket: Socket


proc newServer*(): Server =
  let socket = newSocket()
  socket.bindAddr()
  socket.listen()

  result = Server(socket: socket)


proc getApi*(server: Server): string =
  result = "rosrpc://" & server.socket.getLocalAddr[0] & ":" & $server.socket.getLocalAddr[1]
