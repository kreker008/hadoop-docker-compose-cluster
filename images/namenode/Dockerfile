FROM hadoop_core

ARG HIVE_HOME=/usr/local/hive
ARG HIVE_ARCHIVE_URL=https://dlcdn.apache.org/hive/hive-4.0.0/apache-hive-4.0.0-bin.tar.gz
ARG LIVY_HOME=/usr/local/livy

ENV HIVE_HOME $HIVE_HOME
ENV HIVE_ARCHIVE_URL $HIVE_ARCHIVE_URL
ENV HIVE_JDBC_ULR $HIVE_JDBC_ULR
ENV LIVY_HOME $LIVY_HOME
ENV M2_HOME /opt/apache-maven-3.9.6
ENV TEST test

RUN apt install -y unzip git nano 

#*** HIVE ***
RUN mkdir $HIVE_HOME
RUN wget $HIVE_ARCHIVE_URL
RUN tar -zxf apache-hive*.tar.gz -C $HIVE_HOME --strip-components 1
RUN rm apache-hive*.tar.gz
RUN cp postgresql*.jar $HIVE_HOME/lib/ 
RUN cp $HIVE_HOME/conf/hive-env.sh.template $HIVE_HOME/conf/hive-env.sh
RUN chown -R $HADOOP_USER:$HADOOP_GROUP $HIVE_HOME
RUN printf "\nexport HADOOP_HOME=$HADOOP_HOME " >> $HIVE_HOME/conf/hive-env.sh

#*** MAVEN ***
RUN wget https://dlcdn.apache.org/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz
RUN tar -zxf apache-maven*.tar.gz -C /opt/

#*** LIVY ****
WORKDIR /
RUN git clone https://github.com/apache/incubator-livy.git
RUN git -C ./incubator-livy/ checkout f615f27
RUN mkdir $LIVY_HOME
RUN mv /incubator-livy/* $LIVY_HOME
RUN rm $LIVY_HOME/pom.xml
COPY images/namenode/pom.xml $LIVY_HOME/
WORKDIR $LIVY_HOME
RUN $M2_HOME/bin/mvn clean package -B -V -e -Pspark3 -Pscala-2.12 -Pthriftserver -DskipTests -DskipITs -Dmaven.javadoc.skip=true
RUN mkdir $LIVY_HOME/logs
RUN chown -R $HADOOP_USER:$HADOOP_GROUP $LIVY_HOME

ENTRYPOINT ["bash"]