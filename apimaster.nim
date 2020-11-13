import
  strutils, xmltree, xmlparser,
  ./apislave, ./prototcp, ./xmlrpcclient, ./xmlrpcserver

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

proc getResult(response: XmlNode, item = 2): string =
  result = response.child("params")
                         .child("param")
                         .child("value")
                         .child("array")
                         .child("data")[item].innerText


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

proc lookupNode(client: Client, node: string): string =
  let request = createRequest("lookupNode", client.caller_id, node)
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


proc lookupService(client: Client, service: string): string =
  let request = createRequest("lookupService", client.caller_id, service)
  result = getResult(parseXml(client.xc.call(request)))


proc registerService(client: Client, service, service_api, caller_api: string): string =
  let request = createRequest("registerService", client.caller_id, service, service_api, caller_api)
  result = getResult(parseXml(client.xc.call(request)), 1)

proc unregisterService(client: Client, service, service_api: string): string =
  let request = createRequest("unregisterService", client.caller_id, service, service_api)
  result = getResult(parseXml(client.xc.call(request)), 1)

proc registerSubscriber(client: Client, topic, topic_type, caller_api: string): string =
  let request = createRequest("registerSubscriber", client.caller_id, topic, topic_type, caller_api)
  result = getResult(parseXml(client.xc.call(request)), 1)

proc unregisterSubscriber(client: Client, topic, caller_api: string): string =
  let request = createRequest("unregisterSubscriber", client.caller_id, topic, caller_api)
  result = getResult(parseXml(client.xc.call(request)), 1)

proc registerPublisher(client: Client, topic, topic_type, caller_api: string): string =
  let request = createRequest("registerPublisher", client.caller_id, topic, topic_type, caller_api)
  result = getResult(parseXml(client.xc.call(request)), 1)

proc unregisterPublisher(client: Client, topic, caller_api: string): string =
  let request = createRequest("unregisterPublisher", client.caller_id, topic, caller_api)
  result = getResult(parseXml(client.xc.call(request)), 1)


## Stubs
let client = newClient("localhost", 11311, "/foo")

## getters
# echo client.lookupNode
# echo client.getPublishedTopics
# echo client.getTopicTypes
# echo client.getSystemState
# echo client.getUri
# echo client.lookupService

## setters

# service_api is node's tcp ros server url
let tcp_server = prototcp.newServer()
let service_api = tcp_server.getApi()
echo "service_api ", service_api

# caller_api is slave server url
let api_slave_server = apislave.newServer()
let caller_api = api_slave_server.xs.getApi()
echo "caller_api ", caller_api

# service is the name of the service that appears on ROS
let service = "foo_service"

echo client.registerService(service, service_api, caller_api)
echo client.lookupService(service)
echo client.unregisterService(service, service_api)

let topic = "foo_topic"
let topic_type = "std_msgs/Empty"

echo client.registerPublisher(topic, topic_type, caller_api)
echo client.getPublishedTopics
echo client.unregisterPublisher(topic, caller_api)

echo client.registerSubscriber(topic, topic_type, caller_api)
echo client.getSystemState
echo client.unregisterSubscriber(topic, caller_api)
