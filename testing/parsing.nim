import xmltree
import strutils


proc parseInt(xml: XmlNode): int =
  result = parseInt(xml.innerText)

proc parseDouble(xml: XmlNode): float =
  result = parseFloat(xml.innerText)

proc parseBoolean(xml: XmlNode): bool =
  result = parseBool(xml.innerText)

proc parseString(xml: XmlNode): string =
  result = xml.innerText

proc parseArray(xml: XmlNode): seq[XmlNode] =
  for x in xml.child("array").child("data"):
    result.add(x)


proc testParseInt() =
  var val = newElement("value")
  var i = newElement("int")

  i.add(newText("1"))
  val.add(i)

  echo val
  echo parseInt(val)
  echo ""




proc testParseDouble() =
  var val = newElement("value")
  var i = newElement("double")

  i.add(newText("1.1"))
  val.add(i)

  echo val
  echo parseDouble(val)
  echo ""


proc testParseBoolean() =
  var val = newElement("value")
  var i = newElement("boolean")

  i.add(newText("1"))
  val.add(i)

  echo val
  echo parseBoolean(val)
  echo ""



proc testParseString() =
  var val = newElement("value")
  var i = newElement("string")

  i.add(newText("foo"))
  val.add(i)

  echo val
  echo parseString(val)
  echo ""



proc testParseArray() =
  var val = newElement("value")
  var i = newElement("array")
  var d = newElement("data")
  var val_1 = newElement("value")
  var string_1 = newElement("string")
  var val_2 = newElement("value")
  var string_2 = newElement("string")

  string_1.add(newText("foo"))
  string_2.add(newText("bar"))
  val_1.add(string_1)
  val_2.add(string_2)
  d.add(val_1)
  d.add(val_2)
  i.add(d)
  val.add(i)

  echo val
  echo parseArray(val)
  echo ""


testParseInt()
testParseDouble()
testParseBoolean()
testParseString()
testParseArray()
