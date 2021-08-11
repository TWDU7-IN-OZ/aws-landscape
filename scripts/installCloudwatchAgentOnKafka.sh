#!/usr/bin/env bash

set -xe

usage() {
  echo "Install Cloudwatch agent on Kafka EC2"
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
" >>~/.ssh/config

echo "====Installing Cloudwatch agent on Kafka to monitor disk utilisation===="
ssh kafka.${TRAINING_COHORT}.training <<EOF
sudo yum -y install amazon-cloudwatch-agent
sudo echo '
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "cwagent"
  },
  "metrics": {
    "append_dimensions": {
        "InstanceId": "${aws:InstanceId}"
    },
    "metrics_collected": {
      "disk": {
        "measurement": [
          "used_percent"
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "/data",
          "/"
        ]
      }
    }
  }
}
' | sudo tee /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
sudo systemctl restart amazon-cloudwatch-agent
EOF

echo "====Installation of Cloudwatch agent done===="
