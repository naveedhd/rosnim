# rospy.init_node('listener', anonymous=True)

## node = rospy.impl.init.start_node(os.environ, resolved_node_name, port=xmlrpc_port, tcpros_port=tcpros_port)
### init_tcpros(tcpros_port)

# server.topic_connection_handler = _handler.topic_connection_handler
# server.service_connection_handler = rospy.impl.tcpros_service.service_connection_handler


# if not master_uri:
#     master_uri = rosgraph.get_master_uri()
# if not master_uri:
#     master_uri = DEFAULT_MASTER_URI
# let master_uri = "http://localhost:11311/"

# # _set_caller_id(resolved_name)
# let caller_id = "rosecho"


# handler = ROSHandler(resolved_name, master_uri)
  # subclasses xmlrpchandler which has nothing
  # the internal protocol handler is the socket

# self.reg_man = RegManager(self)
  # subclasses RegistrationListener


# node = rosgraph.xmlrpc.XmlRpcNode(port, handler, on_run_error=_node_run_error)
  # we pass in handler
  # and a run_error function which just logs and shutdown

# node.start()
  # start a thread of self.run()
  # initializes things:
    # bind_address = rosgraph.network.get_bind_address() # 0.0.0.0
    # self.server = ThreadingXMLRPCServer((bind_address, port), log_requests)
      # this is simple xmlrpc server with threading stuff
    # registers handler with this server

  # then serve forever

# wait for the node.uri
  # ideally it should be right with the start but since we start in a thread
  # this is ROS Slave uri

# wait for the handler._is_registered()
  # which is handler.reg_man.is_registered()
    # Node.start() calls handler._ready which starts handler.reg_man.start()
    # which sets the handler registered

# then we return the node

## rospy.core.set_node_uri(node.uri)
## rospy.core.add_shutdown_hook(node.shutdown)

# So the composition is

# ProtocolHandler:
#   Socket / TCPROSserver

# Handler:
#   ProtocolHandler
#   RegistrationHandler

# XmlRpcNode:
#   Handler

# type
#   ClientAddress = tuple
#     address: string
#     port: int

#   TCPServer = object
#     client_address: ClientAddress
#     server_socket: Socket
#     inbound_handler: proc (sock: Socket, client_address: ClientAddress)

#   TCPROSServer = object
#     port: int
#     tcp_server: TCPServer

#   TCPROSHandler = object
#     tcp_ros_server: TCPROSServer

#   ROSHandler = object
#     master_uri: string
#     name: string
#     # protocol_handlers: [Handler]
#     handler: TCPROSHandler

#   XmlRpcNode = object
#     port: int
#     handler: ROSHandler

import asyncdispatch

import masterslave


proc initNode*(name: string): XmlRpcNode =
  result = startNode()


proc spin*() =
  runForever()

