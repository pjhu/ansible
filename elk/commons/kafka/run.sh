nohup bin/zookeeper-server-start.sh config/zookeeper.properties > /data/zookeeper/logs/nohup.out 2>&1&

nohup bin/kafka-server-start.sh config/server.properties & > /data/zookeeper/logs/nohup.out 2>&1&
