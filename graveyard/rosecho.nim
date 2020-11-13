import client
import topics


# -> rospy.init_node('listener', anonymous=True)
let node = initNode("rosnim")


# -> rospy.Subscriber('chatter', String, callback)
proc foo(data: int) =
  echo(data)

let subscriber = newSubscriber("chatter", foo)


# -> rospy.spin()
spin()
