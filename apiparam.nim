import
  xmltree, xmlparser,
  ./apislave, ./xmlrpcclient, ./xmlrpcserver

type
  Client = object
    xc: xmlrpcclient.Client
    caller_id: string


proc newClient(host: string, port: int, caller_id: string): Client =
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

proc decodeGetParamNamesResponse(response: XmlNode): seq[string] =
  for item in response.child("params")
                         .child("param")
                         .child("value")
                         .child("array")
                         .child("data")[2]
                         .child("array")
                         .child("data"):
      result.add(item.innerText)

  # # First element in the array is code
  # result.code = parseInt(data_xml[0].innerText)

  # # Second element is the status message
  # result.status_message = data_xml[1].innerText

  # # Third element is an array of (topic_name, topic_type)
  # let topics_info_xml = data_xml[2].child("array").child("data")

  # for topics in topics_info_xml:
  #   for topic_info in topics:
  #     let topic_spec = topic_info.child("data")
  #     result.topics.add((topic_spec[0].innerText, topic_spec[1].innerText))


proc deleteParam(client: Client, key: string): string =
  let request = createRequest("deleteParam", client.caller_id, key)
  result = getResult(parseXml(client.xc.call(request)), 1)


proc setParam(client: Client, key, value: string): string =
  let request = createRequest("setParam", client.caller_id, key, value)
  result = getResult(parseXml(client.xc.call(request)), 1)


proc getParam(client: Client, key: string): string =
  let request = createRequest("getParam", client.caller_id, key)
  result = getResult(parseXml(client.xc.call(request)))


proc searchParam(client: Client, key: string): string =
  let request = createRequest("searchParam", client.caller_id, key)
  result = getResult(parseXml(client.xc.call(request)))

proc hasParam(client: Client, key: string): string =
  let request = createRequest("hasParam", client.caller_id, key)
  result = getResult(parseXml(client.xc.call(request)))

proc getParamNames(client: Client): seq[string] =
  let request = createRequest("getParamNames", client.caller_id)
  result = decodeGetParamNamesResponse(parseXml(client.xc.call(request)))


proc subscribeParam(client: Client, caller_api, key: string): string =
  let request = createRequest("subscribeParam", client.caller_id, caller_api, key)
  result = getResult(parseXml(client.xc.call(request)))

proc unsubscribeParam(client: Client, caller_api, key: string): string =
  let request = createRequest("unsubscribeParam", client.caller_id, caller_api, key)
  result = getResult(parseXml(client.xc.call(request)), 1)


## Stubs
let client = newClient("localhost", 11311, "/foo")

let param_key = "foo_param"
let param_value = "foo_value"
echo client.setParam(param_key, param_value)
echo client.getParam(param_key)
echo client.searchParam(param_key)
echo client.hasParam(param_key)
echo client.getParamNames()

# caller_api is slave server url
let api_slave_server = apislave.newServer()
let caller_api = api_slave_server.xs.getApi()
echo "caller_api ", caller_api
echo client.subscribeParam(caller_api, param_key)
echo client.unsubscribeParam(caller_api, param_key)

echo client.deleteParam(param_key)

