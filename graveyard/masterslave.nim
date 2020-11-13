import asyncdispatch, asyncnet
import nativesockets

import tcpros

type
  XmlRpcApi = object
    master_uri: string


  RegManager = object
    master_uri: string
    uri: string
    master: XmlRpcApi

  ROSHandler = object
    master_uri: string
    name: string
    # protocol_handlers: [Handler]
    handler: TCPROSHandler
    reg_man: RegManager


  XmlRpcNode* = object
    handler: ROSHandler
    socket: AsyncSocket


## RegManager
proc start(reg_man: var RegManager, uri: string, master_uri: string) =
  reg_man.master_uri = master_uri
  reg_man.uri = uri
  reg_man.master = XmlRpcApi(master_uri: master_uri)


## ROSHandler
proc newROSHandler*(): ROSHandler =
  result = ROSHandler(master_uri: "", name: "", handler: newTCPROSHandler())

proc ready*(ros_handler: var ROSHandler, uri: string) =
  ros_handler.reg_man.start(uri, "")

proc isRegistered*(ros_handler: ROSHandler) {.async} =
  discard


## XmlRpcNode
proc startNode*(): XmlRpcNode =
  result = XmlRpcNode(handler: newROSHandler(), socket: newAsyncSocket())
  result.socket.setSockOpt(OptReuseAddr, true)
  result.socket.bindAddr()
  result.socket.listen()

  echo result.socket.getLocalAddr()

  # server.register_instance(rpc_handler)

  result.handler.ready("")

  # waitFor handler.isRegistered()
