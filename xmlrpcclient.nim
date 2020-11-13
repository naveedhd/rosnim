import
  httpclient


type
  Client* = object
    url: string


proc newClient*(host: string, port: int): Client =
  result = Client(url: "http://" & host & ":" & $port & "/RPC2")


proc call*(client: Client, body: string): string =
  let http_client = newHttpClient(headers=newHttpHeaders({"Content-Type": "text/xml"}))
  defer: http_client.close()

  result = http_client.postContent(client.url, body=body)
