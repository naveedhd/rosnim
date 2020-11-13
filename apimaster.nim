import
  strutils, xmltree, xmlparser,
  ./xmlrpcclient

type
  Client = object
    xc: xmlrpcclient.Client
    caller_id: string

  ResponseGetPublishedTopics* = object
    code*: int
    status_message*: string
    topics*: seq[(string, string)]

  SystemStateEntry* = object
    name*: string
    nodes*: seq[string]

  SystemState* = object
    published_topics*: seq[SystemStateEntry]
    subscribed_topics*: seq[SystemStateEntry]
    provided_services*: seq[SystemStateEntry]

  ResponseGetSystemState* = object
    code*: int
    status_message*: string
    state*: SystemState


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

proc getResult(response: XmlNode): string =
  result = response.child("params")
                         .child("param")
                         .child("value")
                         .child("array")
                         .child("data")[2].innerText


proc responseDecode*(xml_node: XmlNode): ResponseGetPublishedTopics =
  let data_xml = xml_node.child("params")
                         .child("param")
                         .child("value")
                         .child("array")
                         .child("data")

  # First element in the array is code
  result.code = parseInt(data_xml[0].innerText)

  # Second element is the status message
  result.status_message = data_xml[1].innerText

  # Third element is an array of (topic_name, topic_type)
  let topics_info_xml = data_xml[2].child("array").child("data")

  for topics in topics_info_xml:
    for topic_info in topics:
      let topic_spec = topic_info.child("data")
      result.topics.add((topic_spec[0].innerText, topic_spec[1].innerText))


proc responseDecodeState*(xml_node: XmlNode): ResponseGetSystemState =
  let data_xml = xml_node.child("params")
                         .child("param")
                         .child("value")
                         .child("array")
                         .child("data")

  # First element in the array is code
  result.code = parseInt(data_xml[0].innerText)

  # Second element is the status message
  result.status_message = data_xml[1].innerText

  # # Third element is an array of (topic_name, topic_type)
  # let topics_info_xml = data_xml[2].child("array").child("data")

  # for topics in topics_info_xml:
  #   for topic_info in topics:
  #     let topic_spec = topic_info.child("data")
  #     result.topics.add((topic_spec[0].innerText, topic_spec[1].innerText))

proc lookupNode(client: Client): string =
  let request = createRequest("lookupNode", client.caller_id, "foo")
  result = getResult(parseXml(client.xc.call(request)))


proc getPublishedTopics(client: Client): ResponseGetPublishedTopics =
  let request = createRequest("getPublishedTopics", client.caller_id, "")
  let response = parseXml(client.xc.call(request))
  result = responseDecode(response)


proc getTopicTypes(client: Client): seq[string] =
  let request = createRequest("getTopicTypes", client.caller_id)

  let response = parseXml(client.xc.call(request))
  discard response
  # TODO


proc getSystemState(client: Client): ResponseGetSystemState =
  let request = createRequest("getSystemState", client.caller_id)
  let response = parseXml(client.xc.call(request))
  result = responseDecodeState(response)


proc getUri(client: Client): string =
  let request = createRequest("getUri", client.caller_id)
  result = getResult(parseXml(client.xc.call(request)))


proc lookupService(client: Client): string =
  let request = createRequest("lookupService", client.caller_id, "foo")
  result = getResult(parseXml(client.xc.call(request)))


## Stubs
let client = newClient("localhost", 11311, "/foo")

echo client.lookupNode
echo client.getPublishedTopics
echo client.getTopicTypes
echo client.getSystemState
echo client.getUri
echo client.lookupService
