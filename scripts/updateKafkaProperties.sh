#!/usr/bin/env bash

set -xe

usage() {
    echo "Mount EBS to EC2"
}

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

BASTION_PUBLIC_IP=$1
TRAINING_COHORT=$2

echo "====Updating SSH Config===="

echo "
	User ec2-user
	IdentitiesOnly yes
	ForwardAgent yes
	DynamicForward 6789
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null

Host emr-master.${TRAINING_COHORT}.training
    User hadoop

Host *.${TRAINING_COHORT}.training !bastion.${TRAINING_COHORT}.training
	ForwardAgent yes
	ProxyCommand ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ec2-user@${BASTION_PUBLIC_IP} -W %h:%p 2>/dev/null
	User ec2-user
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null

Host bastion.${TRAINING_COHORT}.training
    User ec2-user
    HostName ${BASTION_PUBLIC_IP}
    DynamicForward 6789
" >> ~/.ssh/config

echo "====SSH Config Updated===="

echo "====Updating Kafka Properties===="
ssh kafka.${TRAINING_COHORT}.training <<EOF
sudo su root
mkdir -p /data/kafka
chown -R cp-kafka:confluent /data/kafka
systemctl stop confluent-kafka
systemctl stop confluent-zookeeper
cp -r /var/lib/kafka/* /data/kafka/
sed -i -e 's,log.dirs=/var/lib/kafka,log.dirs=/data/kafka,g' /etc/kafka/server.properties
systemctl start confluent-zookeeper
systemctl start confluent-kafka
EOF
echo "====Updating Kafka Properties Done===="