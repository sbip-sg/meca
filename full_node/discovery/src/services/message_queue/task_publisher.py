import pika
from services.message_queue.queue_config import declare_host_queue
from models.responses import TaskResultModel
from models.requests import OffloadRequest
import models.schema_pb2 as schema
from services.message_queue.result_queue import ResultQueue


class BasicTaskPublisher:
    _class_instance = None
    openQueues = {}

    def __init__(self, mq_url):
        self.mq_url = mq_url
        self.connection = None
        self.channel = None
        self.start_publisher()

    def __new__(cls, mq_url):
        if cls._class_instance is None:
            cls._class_instance = super(BasicTaskPublisher, cls).__new__(cls)
        return cls._class_instance

    def start_publisher(self):
        connection_params = pika.URLParameters(self.mq_url)
        connection_params.blocked_connection_timeout = 60
        self.connection = pika.BlockingConnection(connection_params)

        self.channel = self.connection.channel()
        self.channel.confirm_delivery()

    async def publish(
        self,
        transaction_id: str,
        offload_request: OffloadRequest,
        host_name: str,
        reply_to: str = ResultQueue.result_queue,
    ) -> TaskResultModel:
        task = schema.Task()
        task.id = offload_request.task_id
        task.containerRef = offload_request.container_reference
        task.content = offload_request.content
        if offload_request.resource is not None:
            resource = schema.Resource()
            resource.cpu = offload_request.resource.cpu
            resource.memory = offload_request.resource.memory
            task.resource.CopyFrom(resource)
        if offload_request.runtime is not None:
            task.runtime = offload_request.runtime

        declare_host_queue(self.channel, host_name)
        print("Publishing to queue: " + host_name)
        print(task)
        self.channel.basic_publish(
            exchange="",
            routing_key=host_name,
            properties=pika.BasicProperties(
                correlation_id=transaction_id,
                reply_to=reply_to,
                delivery_mode=pika.spec.PERSISTENT_DELIVERY_MODE,
            ),
            body=task.SerializeToString(),
            mandatory=True,
        )
        return TaskResultModel(
            id=task.id,
            content=transaction_id,
        )

    def close(self):
        self.channel.close()
        self.connection.close()
