#!/bin/bash

chown -R $HADOOP_USER:$HADOOP_GROUP /hadoop/hdfs/datanode
until wget -q --spider http://namenode:8080 && wget -q --spider http://namenode:9870; do
    sleep 1
done	

service ssh start
printf "$HADOOP_DATANODES" > $HADOOP_HOME/etc/hadoop/workers;
(envsubst < /root/utils/configs/core-site.xml) > $HADOOP_HOME/etc/hadoop/core-site.xml && chown $HADOOP_USER:$HADOOP_GROUP $HADOOP_HOME/etc/hadoop/core-site.xml
(envsubst < /root/utils/configs/hdfs-site.xml) > $HADOOP_HOME/etc/hadoop/hdfs-site.xml && chown $HADOOP_USER:$HADOOP_GROUP $HADOOP_HOME/etc/hadoop/hdfs-site.xml
(envsubst < /root/utils/configs/yarn-site.xml) > $HADOOP_HOME/etc/hadoop/yarn-site.xml && chown $HADOOP_USER:$HADOOP_GROUP $HADOOP_HOME/etc/hadoop/yarn-site.xml
(envsubst < /root/utils/configs/mapred-site.xml) > $HADOOP_HOME/etc/hadoop/mapred-site.xml && chown $HADOOP_USER:$HADOOP_GROUP $HADOOP_HOME/etc/hadoop/mapred-site.xml
(envsubst < /root/utils/configs/spark-default.conf) > $SPARK_HOME/conf/spark-default.conf && chown $HADOOP_USER:$HADOOP_GROUP $SPARK_HOME/conf/spark-default.conf
(envsubst < /root/utils/configs/spark-hive-site.xml) > $SPARK_HOME/conf/hive-site.xml && chown $HADOOP_USER:$HADOOP_GROUP $SPARK_HOME/conf/hive-site.xml
su -c "$HADOOP_HOME/bin/hadoop fs -copyFromLocal ${SPARK_HOME}/jars /spark-jars" $HADOOP_USER
su -c "$HADOOP_HOME/bin/hdfs --daemon start datanode" $HADOOP_USER
su -c "$HADOOP_HOME/bin/yarn --daemon start nodemanager" $HADOOP_USER
su -c "$SPARK_HOME/sbin/start-worker.sh spark://namenode:7077" $HADOOP_USER