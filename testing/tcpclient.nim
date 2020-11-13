import net

var socket = newSocket()

let address = "127.0.0.1"
let port = Port(5005)
socket.connect(address, port)

socket.send("Hello, World!")

socket.close()
