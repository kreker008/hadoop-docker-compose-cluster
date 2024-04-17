#!/bin/bash

if [[ ! -f /root/utils/configs/inited || "$RECREATE" -eq 1 ]]; then
	service ssh start
	printf "$HADOOP_DATANODES" > $HADOOP_HOME/etc/hadoop/workers && chown $HADOOP_USER:$HADOOP_GROUP $HADOOP_HOME/etc/hadoop/workers
	printf "$SPARK_WORKERS" > $SPARK_HOME/conf/workers && chown $HADOOP_USER:$HADOOP_GROUP $SPARK_HOME/conf/workers
	(envsubst < /root/utils/configs/core-site.xml) > $HADOOP_HOME/etc/hadoop/core-site.xml && chown $HADOOP_USER:$HADOOP_GROUP $HADOOP_HOME/etc/hadoop/core-site.xml
	(envsubst < /root/utils/configs/hdfs-site.xml) > $HADOOP_HOME/etc/hadoop/hdfs-site.xml && chown $HADOOP_USER:$HADOOP_GROUP $HADOOP_HOME/etc/hadoop/hdfs-site.xml
	(envsubst < /root/utils/configs/yarn-site.xml) > $HADOOP_HOME/etc/hadoop/yarn-site.xml && chown $HADOOP_USER:$HADOOP_GROUP $HADOOP_HOME/etc/hadoop/yarn-site.xml
	(envsubst < /root/utils/configs/mapred-site.xml) > $HADOOP_HOME/etc/hadoop/mapred-site.xml && chown $HADOOP_USER:$HADOOP_GROUP $HADOOP_HOME/etc/hadoop/mapred-site.xml
	(envsubst < /root/utils/configs/spark-defaults.conf) > $SPARK_HOME/conf/spark-defaults.conf && chown $HADOOP_USER:$HADOOP_GROUP $SPARK_HOME/conf/spark-defaults.conf
	(envsubst < /root/utils/configs/hive-site.xml) > $HIVE_HOME/conf/hive-site.xml && chown $HADOOP_USER:$HADOOP_GROUP $HIVE_HOME/conf/hive-site.xml
	su -c "$HADOOP_HOME/bin/hdfs namenode -format" $HADOOP_USER
	su -c "$HADOOP_HOME/bin/hdfs --daemon start namenode" $HADOOP_USER
	su -c "$HADOOP_HOME/bin/yarn --daemon start resourcemanager" $HADOOP_USER
#	su -c "$HADOOP_HOME/bin/mapred --daemon start historyserver" $HADOOP_USER
	su -c "$SPARK_HOME/sbin/start-master.sh" $HADOOP_USER
	su -c "$HADOOP_HOME/bin/hadoop fs -mkdir /tmp" $HADOOP_USER
	su -c "$HADOOP_HOME/bin/hadoop fs -chmod g+w /tmp" $HADOOP_USER
	su -c "$HADOOP_HOME/bin/hadoop fs -mkdir -p /user/hive" $HADOOP_USER
	su -c "$HADOOP_HOME/bin/hadoop fs -chmod g+w /user/hive/" $HADOOP_USER
	su -c "$HADOOP_HOME/bin/hadoop fs -mkdir -p /user/hue" $HADOOP_USER
	su -c "$HADOOP_HOME/bin/hadoop fs -chmod 755 /user/hue" $HADOOP_USER
	su -c "$HADOOP_HOME/bin/hadoop fs -chown hue:supergroup /user/hue" $HADOOP_USER
	su -c "$HADOOP_HOME/bin/hadoop fs -mkdir -p /apps/hive/warehouse" $HADOOP_USER
	su -c "$HADOOP_HOME/bin/hadoop fs -mkdir -p /apps/spark/log" $HADOOP_USER
	su -c "$HADOOP_HOME/bin/hadoop fs -chmod -R a+rw /apps/" $HADOOP_USER
	su -c "$HADOOP_HOME/bin/hadoop fs -copyFromLocal ${SPARK_HOME}/jars /spark-jars" $HADOOP_USER
	su -c "$SPARK_HOME/sbin/start-history-server.sh" $HADOOP_USER
	su -c "$HIVE_HOME/bin/schematool -dbType postgres -initSchema" $HADOOP_USER
	su -c "$HIVE_HOME/bin/hiveserver2 > /dev/null 2>&1 &" $HADOOP_USER
	su -c "$LIVY_HOME/bin/livy-server start" $HADOOP_USER
	touch /root/utils/configs/inited
else
	service ssh start
	(envsubst < /root/utils/configs/core-site.xml) > $HADOOP_HOME/etc/hadoop/core-site.xml && chown $HADOOP_USER:$HADOOP_GROUP $HADOOP_HOME/etc/hadoop/core-site.xml
	(envsubst < /root/utils/configs/hdfs-site.xml) > $HADOOP_HOME/etc/hadoop/hdfs-site.xml && chown $HADOOP_USER:$HADOOP_GROUP $HADOOP_HOME/etc/hadoop/hdfs-site.xml
	(envsubst < /root/utils/configs/yarn-site.xml) > $HADOOP_HOME/etc/hadoop/yarn-site.xml && chown $HADOOP_USER:$HADOOP_GROUP $HADOOP_HOME/etc/hadoop/yarn-site.xml
	(envsubst < /root/utils/configs/mapred-site.xml) > $HADOOP_HOME/etc/hadoop/mapred-site.xml && chown $HADOOP_USER:$HADOOP_GROUP $HADOOP_HOME/etc/hadoop/mapred-site.xml
	(envsubst < /root/utils/configs/spark-default.conf) > $SPARK_HOME/conf/spark-default.conf && chown $HADOOP_USER:$HADOOP_GROUP $SPARK_HOME/conf/spark-default.conf
	(envsubst < /root/utils/configs/hive-site.xml) > $HIVE_HOME/conf/hive-site.xml && chown $HADOOP_USER:$HADOOP_GROUP $HIVE_HOME/conf/hive-site.xmls
	su -c "$HADOOP_HOME/bin/hdfs --daemon start namenode" $HADOOP_USER
	su -c "$HADOOP_HOME/bin/yarn --daemon start resourcemanager" $HADOOP_USER
#	su -c "$HADOOP_HOME/bin/mapred --daemon start historyserver" $HADOOP_USER
	su -c "$SPARK_HOME/sbin/start-master.sh" $HADOOP_USER
	su -c "$SPARK_HOME/sbin/start-history-server.sh" $HADOOP_USER
	su -c "$HIVE_HOME/bin/hiveserver2 > /dev/null 2>&1 &" $HADOOP_USER
	su -c "$LIVY_HOME/bin/livy-server start" $HADOOP_USER
fi
