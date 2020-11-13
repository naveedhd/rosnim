import asyncnet, asyncdispatch

var clients {.threadvar.}: seq[AsyncSocket]

proc processClient(client: AsyncSocket) {.async.} =
  while true:
    let line = await client.recvLine()
    echo("received", line)
    if line.len == 0: break
    # for c in clients:
    #   await c.send(line & "\c\L")

proc serve() {.async.} =
  clients = @[]
  var server = newAsyncSocket()
  server.setSockOpt(OptReuseAddr, true)
  server.bindAddr(Port(5005))
  server.listen()

  while true:
    let client = await server.accept()
    echo("got client: ", client.getLocalAddr())

    clients.add client
    echo("Number of clients: ", clients.len)

    asyncCheck processClient(client)

asyncCheck serve()
runForever()
