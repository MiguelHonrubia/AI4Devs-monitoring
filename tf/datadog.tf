# Datadog AWS Integration Configuration

# Get Datadog external ID for AWS integration
data "datadog_integration_aws_external_id" "external_id" {}

# AWS Integration with Datadog
resource "datadog_integration_aws" "main" {
  account_id  = data.aws_caller_identity.current.account_id
  role_name   = aws_iam_role.datadog_aws_integration.name
  filter_tags = ["env:${var.environment}"]
  host_tags   = ["env:${var.environment}", "project:${var.project_name}"]
  account_specific_namespace_rules = {
    auto_scaling = false
    opswork      = false
  }
  excluded_regions = ["us-gov-west-1", "us-gov-east-1"]
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Datadog Dashboard for AWS Infrastructure Monitoring
resource "datadog_dashboard" "aws_infrastructure" {
  title       = "${var.project_name} AWS Infrastructure Dashboard"
  description = "Comprehensive monitoring dashboard for ${var.project_name} infrastructure"
  layout_type = "ordered"
  is_shared   = false

  # CPU Utilization Widget
  widget {
    timeseries_definition {
      title       = "EC2 CPU Utilization"
      title_size  = "16"
      title_align = "left"
      show_legend = true
      legend_size = "0"

      request {
        q = "avg:aws.ec2.cpuutilization{name:lti-project-*} by {name}"
        style {
          palette    = "dog_classic"
          line_type  = "solid"
          line_width = "normal"
        }
        display_type = "line"
      }

      yaxis {
        scale  = "linear"
        min    = "0"
        max    = "100"
        label  = "Percentage"
        include_zero = true
      }
    }
  }

  # Memory Usage Widget (CloudWatch Agent)
  widget {
    timeseries_definition {
      title       = "Memory Utilization"
      title_size  = "16"
      title_align = "left"
      show_legend = true

      request {
        q = "avg:aws.cloudwatch.mem_used_percent{name:lti-project-*} by {name}"
        style {
          palette    = "purple"
          line_type  = "solid"
          line_width = "normal"
        }
        display_type = "line"
      }

      yaxis {
        scale  = "linear"
        min    = "0"
        max    = "100"
        label  = "Percentage"
        include_zero = true
      }
    }
  }

  # Disk Usage Widget
  widget {
    timeseries_definition {
      title       = "Disk Usage"
      title_size  = "16"
      title_align = "left"
      show_legend = true

      request {
        q = "avg:aws.cloudwatch.disk_used_percent{name:lti-project-*} by {name,device}"
        style {
          palette    = "orange"
          line_type  = "solid"
          line_width = "normal"
        }
        display_type = "line"
      }

      yaxis {
        scale  = "linear"
        min    = "0"
        max    = "100"
        label  = "Percentage"
        include_zero = true
      }
    }
  }

  # Network I/O Widget
  widget {
    timeseries_definition {
      title       = "Network I/O"
      title_size  = "16"
      title_align = "left"
      show_legend = true

      request {
        q = "avg:aws.ec2.networkpacketsin{name:lti-project-*} by {name}"
        style {
          palette    = "green"
          line_type  = "solid"
          line_width = "normal"
        }
        display_type = "line"
      }

      request {
        q = "avg:aws.ec2.networkpacketsout{name:lti-project-*} by {name}"
        style {
          palette    = "green"
          line_type  = "dashed"
          line_width = "normal"
        }
        display_type = "line"
      }

      yaxis {
        scale  = "linear"
        label  = "Packets/sec"
        include_zero = true
      }
    }
  }

  # Instance Status Widget
  widget {
    query_value_definition {
      title       = "Running Instances"
      title_size  = "16"
      title_align = "left"
      autoscale   = true

      request {
        q          = "count_nonzero(avg:aws.ec2.cpuutilization{name:lti-project-*} by {name})"
        aggregator = "last"
      }

      precision = 0
    }
  }

  # Application Health Check Widget
  widget {
    timeseries_definition {
      title       = "Application Response Time"
      title_size  = "16"
      title_align = "left"
      show_legend = true

      request {
        q = "avg:datadog.agent.up{host:lti-project-*} by {host}"
        style {
          palette    = "semantic"
          line_type  = "solid"
          line_width = "normal"
        }
        display_type = "line"
      }

      yaxis {
        scale  = "linear"
        min    = "0"
        max    = "1"
        label  = "Status"
        include_zero = true
      }
    }
  }

  # System Load Widget
  widget {
    timeseries_definition {
      title       = "System Load Average"
      title_size  = "16"
      title_align = "left"
      show_legend = true

      request {
        q = "avg:system.load.1{host:lti-project-*} by {host}"
        style {
          palette    = "cool"
          line_type  = "solid"
          line_width = "normal"
        }
        display_type = "line"
      }

      request {
        q = "avg:system.load.5{host:lti-project-*} by {host}"
        style {
          palette    = "cool"
          line_type  = "dashed"
          line_width = "normal"
        }
        display_type = "line"
      }

      request {
        q = "avg:system.load.15{host:lti-project-*} by {host}"
        style {
          palette    = "cool"
          line_type  = "dotted"
          line_width = "normal"
        }
        display_type = "line"
      }

      yaxis {
        scale  = "linear"
        label  = "Load"
        include_zero = true
      }
    }
  }

  # Docker Container Status Widget
  widget {
    timeseries_definition {
      title       = "Docker Containers"
      title_size  = "16"
      title_align = "left"
      show_legend = true

      request {
        q = "avg:docker.containers.running{host:lti-project-*} by {host,docker_image}"
        style {
          palette    = "dog_classic"
          line_type  = "solid"
          line_width = "normal"
        }
        display_type = "line"
      }

      yaxis {
        scale  = "linear"
        label  = "Containers"
        include_zero = true
      }
    }
  }

  tags = ["env:${var.environment}", "project:${var.project_name}", "terraform:true"]
}

# Datadog Monitor for High CPU Usage
resource "datadog_monitor" "high_cpu" {
  name               = "[${var.project_name}] High CPU Usage"
  type               = "metric alert"
  message            = "CPU usage is above 80% on {{host.name}}. Please investigate."
  escalation_message = "CPU usage is still high on {{host.name}} after 10 minutes."

  query = "avg(last_5m):avg:aws.ec2.cpuutilization{name:lti-project-*} by {name} > 80"

  monitor_thresholds {
    warning  = 70
    critical = 80
  }

  notify_no_data    = false
  renotify_interval = 60

  tags = ["env:${var.environment}", "project:${var.project_name}", "severity:high"]
}

# Datadog Monitor for High Memory Usage
resource "datadog_monitor" "high_memory" {
  name               = "[${var.project_name}] High Memory Usage"
  type               = "metric alert"
  message            = "Memory usage is above 85% on {{host.name}}. Please investigate."
  escalation_message = "Memory usage is still high on {{host.name}} after 10 minutes."

  query = "avg(last_5m):avg:system.mem.pct_usable{host:lti-project-*} by {host} < 15"

  monitor_thresholds {
    warning  = 20
    critical = 15
  }

  notify_no_data    = false
  renotify_interval = 60

  tags = ["env:${var.environment}", "project:${var.project_name}", "severity:high"]
}

# Datadog Monitor for Instance Down
resource "datadog_monitor" "instance_down" {
  name               = "[${var.project_name}] Instance Down"
  type               = "service check"
  message            = "Instance {{host.name}} is down. Please investigate immediately."
  escalation_message = "Instance {{host.name}} is still down after 5 minutes."

  query = "\"datadog.agent.up\".over(\"host:lti-project-*\").last(2).count_by_status()"

  monitor_thresholds {
    critical = 1
    warning  = 1
  }

  notify_no_data    = true
  no_data_timeframe = 10
  renotify_interval = 30

  tags = ["env:${var.environment}", "project:${var.project_name}", "severity:critical"]
} 