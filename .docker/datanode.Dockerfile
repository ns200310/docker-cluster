FROM apache/hadoop-runner
ARG HADOOP_URL=https://dlcdn.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz
ENV HADOOP_HOME /opt/hadoop
ENV HADOOP_CONF_DIR ${HADOOP_HOME}/etc/hadoop
ENV DATANODE_DIR=${HADOOP_HOME}/data/dataNode
WORKDIR /opt
RUN sudo rm -rf ${HADOOP_HOME}
RUN curl -LSs -o hadoop.tar.gz $HADOOP_URL
RUN tar zxf hadoop.tar.gz
RUN rm hadoop.tar.gz 
RUN mv hadoop* hadoop
RUN rm -rf ${HADOOP_HOME}/share/doc
WORKDIR ${HADOOP_HOME}
ADD config/log4j.properties ${HADOOP_HOME}/etc/hadoop/log4j.properties
RUN sudo chown -R hadoop:users ${HADOOP_HOME}/etc/hadoop/*

RUN mkdir -p ${DATANODE_DIR}
COPY ../init-datanode.sh /usr/local/bin/init-datanode.sh
RUN sudo chmod +x /usr/local/bin/init-datanode.sh
ENTRYPOINT ["/usr/local/bin/init-datanode.sh"]