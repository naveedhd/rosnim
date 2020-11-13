import asyncnet, asyncdispatch

var socket = newAsyncSocket()

let address = "127.0.0.1"
let port = Port(5005)
waitFor socket.connect(address, port)

waitFor socket.send("Hello, World!")

socket.close()
