import socket
import time
import struct
import rclpy
from rclpy.serialization import serialize_message
from std_msgs.msg import String

def send_ros2_message(server_ip, server_port, topic_name, frequency=70):
    """
    发送真正的ROS2序列化消息
    """
    interval = 1.0 / frequency
    rclpy.init()
    node = rclpy.create_node('tcp_client')

    counter = 0

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect((server_ip, server_port))
        while rclpy.ok():
            try:
                # 创建并序列化ROS2消息
                msg = String()
                msg.data = "34" * 1000
                message_data = serialize_message(msg)

                # 构建协议消息
                topic_bytes = topic_name.encode('utf-8')
                message = (
                    struct.pack('<I', len(topic_bytes)) +
                    topic_bytes +
                    struct.pack('<I', len(message_data)) +
                    message_data
                )

                s.send(message)
                counter += 1
                if counter > 70:
                    counter = 0
                print(f"Sent ROS2 message {len(message_data)}")

            except Exception as e:
                print(f"Error: {e}")
                break

        time.sleep(interval)

    node.destroy_node()
    rclpy.shutdown()

# 使用
if __name__ == "__main__":
    # send_ros2_message("10.42.0.1", 10000, "/test_msg", frequency=70)
    send_ros2_message("10.42.0.1", 10000, "", frequency=70)
