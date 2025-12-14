FROM apache/hadoop-runner
ARG HADOOP_URL=https://dlcdn.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz
ARG SPARK_URL=https://archive.apache.org/dist/spark/spark-3.3.1/spark-3.3.1-bin-hadoop3.tgz
ARG SBT_URL= https://www.scala-sbt.org/sbt-rpm.repo
ARG HADOOP_ZIP=hadoop.tar.gz
ARG SPARK_ZIP=spark-3.3.1-bin-hadoop3.tgz
ENV HADOOP_HOME /opt/hadoop
WORKDIR /opt
RUN sudo rm -rf ${HADOOP_HOME}
RUN curl -LSs -o ${HADOOP_ZIP} $HADOOP_URL
RUN tar zxf ${HADOOP_ZIP}
RUN rm ${HADOOP_ZIP} 
RUN mv hadoop* hadoop
RUN rm -rf $HADOOP_HOME/share/doc
RUN curl ${SPARK_URL} -o ${SPARK_ZIP}
RUN tar zxf ${SPARK_ZIP}
RUN rm -rf ${SPARK_ZIP}
WORKDIR $HADOOP_HOME
ADD config/log4j.properties $HADOOP_HOME/etc/hadoop/log4j.properties
RUN sudo chown -R hadoop:users $HADOOP_HOME/etc/hadoop/*
ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop
ENV DATANODE_DIR=$HADOOP_HOME/data/dataNode

ENV NAMENODE_DIR=$HADOOP_HOME/data/nameNode

RUN mkdir -p ${NAMENODE_DIR}
ENV SPARK_HOME /opt/spark-3.3.1-bin-hadoop3/bin
COPY start-hdfs.sh /usr/local/bin/start-hdfs.sh

# Make the script executable
RUN sudo chmod +x /usr/local/bin/start-hdfs.sh


RUN sudo curl -L $SBT_URL > sbt-rpm.repo
RUN sudo mv sbt-rpm.repo /etc/yum.repos.d/
RUN sudo yum install -y sbt
RUN sudo yum clean all

ENTRYPOINT ["/usr/local/bin/start-hdfs.sh"]
EXPOSE 9000 9870