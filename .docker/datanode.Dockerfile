FROM apache/hadoop-runner
ARG HADOOP_URL=https://dlcdn.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz
ENV HADOOP_HOME /opt/hadoop
WORKDIR /opt
RUN sudo rm -rf /opt/hadoop
RUN curl -LSs -o hadoop.tar.gz $HADOOP_URL
RUN tar zxf hadoop.tar.gz
RUN rm hadoop.tar.gz 
RUN mv hadoop* hadoop
RUN rm -rf ${HADOOP_HOME}/share/doc
WORKDIR ${HADOOP_HOME}
ADD config/log4j.properties /opt/hadoop/etc/hadoop/log4j.properties
RUN sudo chown -R hadoop:users ${HADOOP_HOME}/etc/hadoop/*
ENV HADOOP_CONF_DIR /opt/hadoop/etc/hadoop
ENV DATANODE_DIR=${HADOOP_HOME}/data/dataNode
# The init script assumes this path exists
RUN mkdir -p ${DATANODE_DIR}
COPY ../init-datanode.sh /usr/local/bin/init-datanode.sh
RUN sudo chmod +x /usr/local/bin/init-datanode.sh
ENTRYPOINT ["/usr/local/bin/init-datanode.sh"]