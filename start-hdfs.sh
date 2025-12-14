#!/bin/bash
set -e

NAMENODE_DIR="/opt/hadoop/data/nameNode"

if [ ! -d "$NAMENODE_DIR/current" ]; then
    echo "Formatting Master as no existing metadata found."
    hdfs namenode -format -force -nonInteractive
else
    echo "Master already formatted. Skipping format step."
fi

echo "Starting YARN ResourceManager Service..."
yarn resourcemanager &

echo "Starting HDFS Master Service..."
hdfs namenode