import
  xmltree, xmlparser,
  ./xmlrpcclient, ./xmlrpcserver

type
  Client = object
    xc: xmlrpcclient.Client
    caller_id: string

  Server = object
    xs*: xmlrpcserver.Server


proc newClient*(host: string, port: int, caller_id: string): Client =
  result = Client(xc: xmlrpcclient.newClient(host, port), caller_id: caller_id)

proc createRequest(method_name: string, params: varargs[string]): string =
  var method_name_xml = newElement("methodName")
  method_name_xml.add(newText(method_name))

  var params_xml = newElement("params")

  for param in params:
    var value_xml = newElement("value")
    value_xml.add(newText(param))
    params_xml.add(value_xml)

  result = $newXmlTree("methodCall", [method_name_xml, params_xml])

proc getResult(response: XmlNode, item = 2): string =
  result = response.child("params")
                         .child("param")
                         .child("value")
                         .child("array")
                         .child("data")[item].innerText


proc getPid*(client: Client): string =
  let request = createRequest("getPid", client.caller_id)
  result = getResult(parseXml(client.xc.call(request)))


## TODO add more api functions as required

proc newServer*(): Server =
  result = Server(xs: xmlrpcserver.newServer())
