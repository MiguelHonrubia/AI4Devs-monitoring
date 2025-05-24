#!/bin/bash
yum update -y
sudo yum install -y docker

# Iniciar el servicio de Docker
sudo service docker start

# Install Datadog Agent
# Set Datadog API key (this should be passed as a variable)
DD_API_KEY="${datadog_api_key}"
DD_SITE="${datadog_site}"

# Download and install Datadog Agent
bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script_agent7.sh)"

# Configure Datadog Agent
cat > /etc/datadog-agent/datadog.yaml << EOF
api_key: $DD_API_KEY
site: $DD_SITE
hostname: lti-project-frontend-${timestamp}
tags:
  - env:${environment}
  - project:${project_name}
  - service:frontend
  - instance_type:frontend

# Enable process monitoring
process_config:
  enabled: "true"

# Enable Docker monitoring
docker_labels_as_tags:
  "*": true

# Enable system probe for network monitoring
system_probe_config:
  enabled: true

# Enable logs collection
logs_enabled: true
logs_config:
  container_collect_all: true
EOF

# Enable and start the Datadog Agent
sudo systemctl enable datadog-agent
sudo systemctl start datadog-agent

# Configure Docker integration for Datadog
cat > /etc/datadog-agent/conf.d/docker.d/conf.yaml << EOF
init_config:

instances:
  - url: "unix://var/run/docker.sock"
    new_tag_names: true
    collect_container_size: true
    collect_images_stats: true
    collect_image_size: true
    collect_disk_stats: true
EOF

# Restart Datadog agent to apply Docker configuration
sudo systemctl restart datadog-agent

# Descargar y descomprimir el archivo frontend.zip desde S3
aws s3 cp s3://ai4devs-project-code-bucket/frontend.zip /home/ec2-user/frontend.zip
unzip /home/ec2-user/frontend.zip -d /home/ec2-user/

# Construir la imagen Docker para el frontend
cd /home/ec2-user/frontend
sudo docker build -t lti-frontend .

# Ejecutar el contenedor Docker
sudo docker run -d -p 80:80 \
  --label "service=lti-frontend" \
  --label "env=${environment}" \
  --label "project=${project_name}" \
  lti-frontend

# Install CloudWatch Agent for enhanced monitoring
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
sudo rpm -U ./amazon-cloudwatch-agent.rpm

# Configure CloudWatch Agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << EOF
{
  "metrics": {
    "namespace": "CWAgent",
    "metrics_collected": {
      "cpu": {
        "measurement": [
          "cpu_usage_idle",
          "cpu_usage_iowait",
          "cpu_usage_user",
          "cpu_usage_system"
        ],
        "metrics_collection_interval": 60,
        "totalcpu": false
      },
      "disk": {
        "measurement": [
          "used_percent"
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "*"
        ]
      },
      "diskio": {
        "measurement": [
          "io_time"
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "*"
        ]
      },
      "mem": {
        "measurement": [
          "mem_used_percent"
        ],
        "metrics_collection_interval": 60
      },
      "netstat": {
        "measurement": [
          "tcp_established",
          "tcp_time_wait"
        ],
        "metrics_collection_interval": 60
      },
      "swap": {
        "measurement": [
          "swap_used_percent"
        ],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF

# Start CloudWatch Agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -s

# Timestamp to force update
echo "Timestamp: ${timestamp}"
