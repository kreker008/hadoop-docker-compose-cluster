FROM ubuntu:24.04

ARG HADOOP_GROUP=default_grp
ARG HADOOP_USER=default_usr
ARG HADOOP_USER_PASS=123456
ARG HADOOP_ARCHIVE_URL=https://dlcdn.apache.org/hadoop/common/hadoop-3.4.0/hadoop-3.4.0.tar.gz
ARG HADOOP_HOME=/usr/local/hadoop
ARG SPARK_HOME=/usr/local/spark
ARG SPARK_ARCHIVE_URL=https://dlcdn.apache.org/spark/spark-3.5.1/spark-3.5.1-bin-hadoop3.tgz
ARG POSTGRES_JDBC_URL=https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.3/postgresql-42.7.3.jar

ENV HADOOP_GROUP $HADOOP_GROUP
ENV HADOOP_USER $HADOOP_USER
ENV HADOOP_USER_PASS $HADOOP_USER_PASS
ENV HADOOP_ARCHIVE_URL $HADOOP_ARCHIVE_URL
ENV HADOOP_HOME $HADOOP_HOME
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
ENV HADOOP_HDFS_HOME $HADOOP_HOME
ENV HADOOP_MAPRED_HOME $HADOOP_HOME
ENV HADOOP_COMMON_HOME $HADOOP_HOME
ENV HADOOP_COMMON_LIB_NATIVE_DIR $HADOOP_HOME/lib/native
ENV HADOOP_OPTS "$HADOOP_OPTS -Djava.library.path=$HADOOP_HOME/lib/native"
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV YARN_HOME $HADOOP_HOME
ENV SPARK_ARCHIVE_URL=$SPARK_ARCHIVE_URL
ENV SPARK_HOME $SPARK_HOME
ENV PYSPARK_PYTHON /usr/bin/python3
ENV PYSPARK_DRIVER_PYTHON python3
ENV PATH "$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$SPARK_HOME/bin"
ENV POSTGRES_JDBC_URL=$POSTGRES_JDBC_URL	

RUN apt update -y && apt upgrade -y && apt install -y openjdk-8-jdk openssh-server gettext-base

#Добавление группы и пользователя для hadoop
RUN addgroup ${HADOOP_GROUP} && printf "${HADOOP_USER_PASS}\n${HADOOP_USER_PASS}\nY\n" | adduser --ingroup ${HADOOP_GROUP} ${HADOOP_USER}

#*** HADOOP ***
#Скачивание и распаковка hadoop
RUN mkdir $HADOOP_HOME
RUN wget $HADOOP_ARCHIVE_URL && tar -zxf hadoop-*.tar.gz -C $HADOOP_HOME --strip-components 1 && rm hadoop-*.tar.gz
RUN mkdir $HADOOP_HOME/logs && mkdir -p /hadoop/hdfs/namenode && mkdir -p /hadoop/hdfs/datanode
RUN chown -R $HADOOP_USER:$HADOOP_GROUP $HADOOP_HOME && chown -R $HADOOP_USER:$HADOOP_GROUP /hadoop/hdfs/
#Настройка *env.sh hadoop
RUN sed -i "s/# export JAVA_HOME=/export JAVA_HOME=\/usr\/lib\/jvm\/java-8-openjdk-amd64/" $HADOOP_HOME/etc/hadoop/hadoop-env.sh
#Исправляет ошибку доступа через рефлексию JAVA
#RUN sed -i '0,/.*# export YARN_RESOURCEMANAGER_OPTS=.*/s//export YARN_RESOURCEMANAGER_OPTS="$YARN_RESOURCEMANAGER_OPTS --add-opens java.base\/java.lang=ALL-UNNAMED"/' $HADOOP_HOME/etc/hadoop/yarn-env.sh
#RUN sed -i '0,/.*# export YARN_NODEMANAGER_OPTS=.*/s//export YARN_NODEMANAGER_OPTS="$YARN_NODEMANAGER_OPTS --add-opens java.base\/java.lang=ALL-UNNAMED"/' $HADOOP_HOME/etc/hadoop/yarn-env.sh

#*** SPARK ***
#Скачивание и распаковка spark
RUN mkdir $SPARK_HOME && mkdir /tmp/spark-events && mkdir /var/log/spark
RUN wget $SPARK_ARCHIVE_URL && tar -zxf spark*.tgz -C $SPARK_HOME --strip-components 1 && rm spark*.tgz
RUN chown -R $HADOOP_USER:$HADOOP_GROUP $SPARK_HOME &&\
	chown -R $HADOOP_USER:$HADOOP_GROUP /tmp/spark-events &&\
	chown -R $HADOOP_USER:$HADOOP_GROUP /var/log/spark
#Настройка *env.sh spark
RUN cp $SPARK_HOME/conf/spark-env.sh.template $SPARK_HOME/conf/spark-env.sh
RUN printf "export SPARK_MASTER_HOST=namenode\nexport PYSPARK_PYTHON=/usr/bin/python3\nexport PYSPARK_DRIVER_PYTHON=python3\nexport HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop" >> $SPARK_HOME/conf/spark-env.sh
#Установка JDBC
RUN wget $POSTGRES_JDBC_URL && cp postgresql*.jar $SPARK_HOME/jars/ 

USER $HADOOP_USER
#Настройка ssh
RUN printf "\n" | ssh-keygen -t rsa -P "" &&\
	cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys &&\
	printf "\nHost *\n\tStrictHostKeyChecking no" >> ~/.ssh/config

USER root
ENTRYPOINT ["bash"]