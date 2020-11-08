## the connection between this and sockets?
##
## TCPROSHandler
## 1. in create_transport()
##  sub = rospy.impl.registration.get_topic_manager().get_subscriber_impl(resolved_name)
##  sub.add_connection(conn)
## 2. topic_connection_handler()
##   tm = rospy.impl.registration.get_topic_manager()
##   topic = tm.get_publisher_impl(resolved_topic_name)
##   topic.add_connection(transport)
##
## get_topic_manager() is TopicManager()
##
## right now we have bypassed TopicManager
## but Topic manager goes to TopicImpl (basically a collection)

type
  Registration = enum
    PUB, SUB, SRV

  TopicImpl[T] = object
    # connections: seq[int]
    # connection_poll: Poller

  SubscriberImpl[T] = object
    topic_impl: TopicImpl[T]
    callback: proc (data: T)
    # callbacks: seq[int]
    # queue_size: int

  Topic[T] = object
    name: string
    reg_type: Registration
    # md5sum: string
    impl: SubscriberImpl[T]  # TopicImpl

  Subscriber[T] = object
    topic: Topic[T]
    # callback: proc (data: T)


## SubscriberImpl
proc newSubscriberImpl[T](callback: proc (data: T)): SubscriberImpl[T] =
  result = SubscriberImpl[T](callback: callback)


## Topic
proc newTopic[T](name: string, reg_type: Registration, callback: proc (data: T)): Topic[T] =
  result = Topic[T](name: name, reg_type: reg_type, impl: newSubscriberImpl[T](callback))


## Subscriber
proc newSubscriber*[T](name: string, callback: proc (data: T)): Subscriber[T] =
  result = Subscriber[T](topic: newTopic[T](name, SUB, callback))
