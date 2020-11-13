import net

var socket = newSocket()
socket.bindAddr(port=Port(5005))
socket.listen()

var client: Socket
var address = ""

socket.acceptAddr(client, address)
echo("Client connected from: ", address)

let data = client.recv(1024)
echo("data received ", data)

socket.close()
