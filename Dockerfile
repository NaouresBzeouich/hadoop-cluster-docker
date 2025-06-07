FROM ubuntu:latest

WORKDIR /root

# install requisites
RUN apt-get update && apt-get install -y openssh-server openjdk-8-jdk ssh wget curl vim python3 && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update
RUN apt-get install -y python3 python3-pip
RUN apt-get update && apt-get install -y python3-pip python3-setuptools
    

# Install Hadoop
RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz && \
    tar -xzf hadoop-3.3.6.tar.gz && \
    mv hadoop-3.3.6 /usr/local/hadoop && \
    rm hadoop-3.3.6.tar.gz


# Install Kafka
RUN wget https://archive.apache.org/dist/kafka/3.6.1/kafka_2.13-3.6.1.tgz && \
    tar -xzf kafka_2.13-3.6.1.tgz && \
    mv kafka_2.13-3.6.1 /usr/local/kafka && \
    rm kafka_2.13-3.6.1.tgz

# set environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 
ENV HADOOP_HOME=/usr/local/hadoop
ENV YARN_HOME=/usr/local/hadoop
ENV SPARK_HOME=/usr/local/spark
ENV KAFKA_HOME=/usr/local/kafka
ENV HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop
ENV YARN_CONF_DIR=/usr/local/hadoop/etc/hadoop 
ENV LD_LIBRARY_PATH=/usr/local/hadoop/lib/native:$LD_LIBRARY_PATH
ENV HBASE_HOME=/usr/local/hbase
ENV CLASSPATH=$CLASSPATH:/usr/local/hbase/lib/*
ENV PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin:/usr/local/spark/bin:/usr/local/kafka/bin:/usr/local/hbase/bin 

# ssh without key
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys

RUN mkdir -p ~/hdfs/namenode && \
    mkdir -p ~/hdfs/datanode && \
    mkdir $HADOOP_HOME/logs

RUN mkdir -p ~/.ssh $HADOOP_HOME/etc/hadoop $SPARK_HOME/conf $HBASE_HOME/conf /root

COPY config/* /tmp/

RUN mv /tmp/ssh_config ~/.ssh/config && \
    mv /tmp/hadoop-env.sh /usr/local/hadoop/etc/hadoop/hadoop-env.sh && \
    mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
    mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml && \
    mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    mv /tmp/workers $HADOOP_HOME/etc/hadoop/workers && \
    mv /tmp/start-hadoop.sh ~/start-hadoop.sh && \
    mv /tmp/hbase-env.sh $HBASE_HOME/conf/hbase-env.sh && \
    mv /tmp/hbase-site.xml $HBASE_HOME/conf/hbase-site.xml 

RUN chmod +x ~/start-hadoop.sh
    
RUN chmod +x ~/start-hadoop.sh && \
    chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh 

# format namenode
RUN /usr/local/hadoop/bin/hdfs namenode -format

CMD [ "sh", "-c", "service ssh start; bash"]

