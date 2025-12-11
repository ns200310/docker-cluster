FROM apache/hadoop-runner
ARG HADOOP_URL=https://dlcdn.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz
WORKDIR /opt
RUN sudo rm -rf /opt/hadoop
RUN curl -LSs -o hadoop.tar.gz $HADOOP_URL
RUN tar zxf hadoop.tar.gz
RUN rm hadoop.tar.gz 
RUN mv hadoop* hadoop
RUN rm -rf /opt/hadoop/share/doc
# FIX 1: Update dead CentOS 7 repositories to the Vault
RUN sudo sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sudo sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

# FIX 2: Install Kerberos Workstation (Correct package for CentOS)
RUN sudo yum install -y krb5-workstation openssl11-libs
WORKDIR /opt/hadoop
ADD config/log4j.properties /opt/hadoop/etc/hadoop/log4j.properties
RUN sudo chown -R hadoop:users /opt/hadoop/etc/hadoop/*
ENV HADOOP_CONF_DIR /opt/hadoop/etc/hadoop
ENV DATANODE_DIR=/opt/hadoop/data/dataNode
# The init script assumes this path exists
RUN mkdir -p ${DATANODE_DIR}
COPY ../init-datanode.sh /usr/local/bin/init-datanode.sh
RUN sudo chmod +x /usr/local/bin/init-datanode.sh
ENTRYPOINT ["/usr/local/bin/init-datanode.sh"]