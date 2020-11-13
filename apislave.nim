import ./xmlrpcserver

type
  Server = object
    xs*: xmlrpcserver.Server


proc newServer*(): Server =
  result = Server(xs: xmlrpcserver.newServer())

