FROM apache/hadoop-runner
ARG HADOOP_URL=https://dlcdn.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz
ARG SPARK_URL=https://archive.apache.org/dist/spark/spark-3.3.1/spark-3.3.1-bin-hadoop3.tgz
ARG HADOOP_ZIP=hadoop.tar.gz
ARG SPARK_ZIP=spark-3.3.1-bin-hadoop3.tgz
WORKDIR /opt
RUN sudo rm -rf /opt/hadoop
RUN curl -LSs -o ${HADOOP_ZIP} $HADOOP_URL
RUN tar zxf ${HADOOP_ZIP}
RUN rm ${HADOOP_ZIP} 
RUN mv hadoop* hadoop
RUN rm -rf /opt/hadoop/share/doc
RUN curl ${SPARK_URL} -o ${SPARK_ZIP}
RUN tar zxf ${SPARK_ZIP}
RUN rm -rf ${SPARK_ZIP}
# 1. Fix CentOS 7 EOL repositories (Point to vault)
RUN sudo sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sudo sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

# 2. Install the correct Kerberos package for CentOS
RUN sudo yum install -y krb5-workstation openssl11-libs
WORKDIR /opt/hadoop
ADD config/log4j.properties /opt/hadoop/etc/hadoop/log4j.properties
RUN sudo chown -R hadoop:users /opt/hadoop/etc/hadoop/*
ENV HADOOP_CONF_DIR /opt/hadoop/etc/hadoop
ENV DATANODE_DIR=/opt/hadoop/data/dataNode

ENV NAMENODE_DIR=/opt/hadoop/data/nameNode

RUN mkdir -p ${NAMENODE_DIR}
ENV SPARK_HOME /opt/spark-3.3.1-bin-hadoop3/bin
COPY start-hdfs.sh /usr/local/bin/start-hdfs.sh

# Make the script executable
RUN sudo chmod +x /usr/local/bin/start-hdfs.sh

ENTRYPOINT ["/usr/local/bin/start-hdfs.sh"]

RUN sudo curl -L https://www.scala-sbt.org/sbt-rpm.repo > sbt-rpm.repo && \
    sudo mv sbt-rpm.repo /etc/yum.repos.d/ && \
    sudo yum install -y sbt && \
    sudo yum clean all

EXPOSE 9000 9870