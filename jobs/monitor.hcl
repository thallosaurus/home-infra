job "monitor" {
  group "prometheus" {
    network {
      #mode = "bridge"
      dns {
        servers = ["10.0.0.1"]
      }
      port "http" {
        to = "9090"
      }
    }

    service {
      name = "prometheus"
      port = "http"

      tags = [
        "traefik",
        "traefik.enable=true",
        "traefik.http.routers.prometheus.rule=Host(`prometheus.apps.cyber.psych0si.is`) && PathPrefix(`/`)",
        "traefik.http.routers.prometheus.entrypoints=http"
      ]
    }

    volume "pdata" {
      type            = "csi"
      read_only       = false
      source          = "nfs_prometheus"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    task "prometheus" {
      driver = "docker"

      template {
        destination     = "local/alert.rules.yml"
        right_delimiter = "#{{"
        left_delimiter  = "}}#"
        data            = <<EOH
groups:
- name: alert.rules
  rules:
  - alert: InstanceDown
    expr: monitor_status == 0
    for: 1m
    labels:
      severity: "critical"
    annotations:
      summary: "Endpoint {{ $labels.instance }} down"
      description: "{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 1 minutes."
        EOH
      }

      template {
        destination = "local/prometheus.yml"
        data        = <<EOH
{{- with nomadVar "nomad/jobs/monitor" -}}

global:
  scrape_interval:     15s # By default, scrape targets every 15 seconds.

  # Attach these labels to any time series or alerts when communicating with
  # external systems (federation, remote storage, Alertmanager).
  external_labels:
    monitor: 'codelab-monitor'

rule_files:
  - alert.rules.yml
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      {{ range service "alertmanager" -}}
      - '{{ .Address }}:{{ .Port }}'
      {{ end }}

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  - job_name: 'nomad_metrics'

    consul_sd_configs:
    - server: '10.0.0.1:8500'
      services: ['nomad-client', 'nomad']
    relabel_configs:
    - source_labels: ['__meta_consul_tags']
      regex: '(.*)http(.*)'
      action: keep

    scrape_interval: 5s
    metrics_path: /v1/metrics

    params:
      format: ['prometheus']
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'

    # Override the global default and scrape targets from this job every 5 seconds.
    scrape_interval: 5s

    static_configs:
      - targets: ['localhost:9090']
  - job_name : 'traefik'
    static_configs:
      - targets: ['traefik-dashboard.apps.cyber.psych0si.is']

  # Example Prometheus scrape_configs entry

  - job_name: "hoass"
    scrape_interval: 60s
    metrics_path: /api/prometheus
    authorization:
      credentials: "{{ .hoass_prom_key }}"
    scheme: http
    static_configs:
      - targets: ['assistant.apps.cyber.psych0si.is']

  - job_name: 'uptime'
    scrape_interval: 30s
    scheme: http
    metrics_path: '/metrics'
    static_configs:
      - targets: ['kuma.apps.cyber.psych0si.is']
    basic_auth: # Only needed if authentication is enabled (default) 
      username: akasha
      password: {{ .kuma_pw }}

{{- end -}}
        EOH
      }

      volume_mount {
        volume      = "pdata"
        destination = "/prometheus"
        read_only   = false
      }
      user = "root"

      config {
        mount {
          type   = "bind"
          source = "local/prometheus.yml"
          target = "/etc/prometheus/prometheus.yml"
        }

        mount {
          type   = "bind"
          source = "local/alert.rules.yml"
          target = "/etc/prometheus/alert.rules.yml.yml"
        }

        image = "prom/prometheus"
        ports = ["http"]
        args  = ["--config.file=/etc/prometheus/prometheus.yml", "--web.external-url=http://prometheus.apps.cyber.psych0si.is/"]
      }

      resources {
        cpu = 500
      }
    }
  }

  group "alertmanager" {

    service {
      name = "alertmanager"
      port = "http"

      tags = [
        "traefik",
        "traefik.enable=true",
        "traefik.http.routers.alertmanager.rule=Host(`alertmanager.apps.cyber.psych0si.is`) && PathPrefix(`/`)",
        "traefik.http.routers.alertmanager.entrypoints=http"
      ]
    }

    volume "alertmanager-data" {
      type            = "csi"
      read_only       = false
      source          = "nfs_alertmanager"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    network {
      port "http" {
        to = "9093"
      }
    }
    task "alertmanager" {
      driver = "docker"

      template {
        data        = <<EOH
{{- with nomadVar "nomad/jobs/monitor" -}}

global:
  # The smarthost and SMTP sender used for mail notifications.
  smtp_smarthost: 'localhost:25'
  smtp_from: 'alertmanager@example.org'
  smtp_auth_username: 'alertmanager'
  smtp_auth_password: 'password'

# The directory from which notification templates are read.
templates:
  - '/etc/alertmanager/template/*.tmpl'

# The root route on which each incoming alert enters.
route:
  # The labels by which incoming alerts are grouped together. For example,
  # multiple alerts coming in for cluster=A and alertname=LatencyHigh would
  # be batched into a single group.
  #
  # To aggregate by all possible labels use '...' as the sole label name.
  # This effectively disables aggregation entirely, passing through all
  # alerts as-is. This is unlikely to be what you want, unless you have
  # a very low alert volume or your upstream notification system performs
  # its own grouping. Example: group_by: [...]
  group_by: ['alertname']

  # When a new group of alerts is created by an incoming alert, wait at
  # least 'group_wait' to send the initial notification.
  # This way ensures that you get multiple alerts for the same group that start
  # firing shortly after another are batched together on the first
  # notification.
  group_wait: 30s

  # When the first notification was sent, wait 'group_interval' to send a batch
  # of new alerts that started firing for that group.
  group_interval: 5m

  # If an alert has successfully been sent, wait 'repeat_interval' to
  # resend them.
  repeat_interval: 3h

  # A default receiver
  receiver: discord


# Inhibition rules allow to mute a set of alerts given that another alert is
# firing.
# We use this to mute any warning-level notifications if the same alert is
# already critical.
inhibit_rules:
  - source_matchers: [severity="critical"]
    target_matchers: [severity="warning"]
    # Apply inhibition if the alertname is the same.
    # CAUTION:
    #   If all label names listed in `equal` are missing
    #   from both the source and target alerts,
    #   the inhibition rule will apply!
    equal: [alertname, cluster, service]


receivers:
- name: discord
  discord_configs:
  - webhook_url: {{ .discord_webhook_url }}

{{- end -}}
        EOH
        destination = "local/alertmanager.yml"
      }
      volume_mount {
        volume      = "alertmanager-data"
        destination = "/data"
        read_only   = false
      }
      config {
        image = "quay.io/prometheus/alertmanager"
        ports = ["http"]
        args  = ["--config.file=/config/alertmanager.yml", "--log.level=debug", "--web.external-url=http://alertmanager.apps.cyber.psych0si.is/"]

        mount {
          type   = "bind"
          source = "local/alertmanager.yml"
          target = "/config/alertmanager.yml"
        }
      }

      resources {
        cpu = 500
      }
    }
  }

  group "grafana" {
    network {
      mode = "bridge"
      dns {
        servers = ["10.0.0.1"]
      }
      port "http" {
        to = "3000"
      }
    }

    service {
      name = "grafana"
      port = "http"

      tags = [
        "traefik",
        "traefik.enable=true",
        "traefik.http.routers.grafana.rule=Host(`grafana.apps.cyber.psych0si.is`) && PathPrefix(`/`)",
        "traefik.http.routers.grafana.entrypoints=http"
      ]
    }

    volume "gdata" {
      type            = "csi"
      read_only       = false
      source          = "nfs_grafana"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    task "grafana" {
      driver = "docker"
      user   = "root"

      volume_mount {
        volume      = "gdata"
        destination = "/var/lib/grafana"
        read_only   = false
      }
      config {
        image = "grafana/grafana"
        ports = ["http"]
      }

      resources {
        cpu = 1000
      }
    }
  }
  /*
  group "influxdb" {
    network {
      #mode = "bridge"
      port "http" {
        to = "8086"
      }
    }

    volume "influx-data" {
      type            = "csi"
      read_only       = false
      source          = "nfs_influxdb"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    task "influxdb" {
      driver = "docker"
      volume_mount {
        volume      = "influx-data"
        destination = "/var/lib/influxdb2"
        read_only   = false
      }
      config {
        image = "influxdb:2"
        ports = ["http"]
      }

      service {
        name = "influxdb"
        port = "http"

        tags = [
          "traefik",
          "traefik.enable=true",
          "traefik.http.routers.influxdb.rule=Host(`influxdb.apps.cyber.psych0si.is`) && PathPrefix(`/`)",
          "traefik.http.routers.influxdb.entrypoints=http"
        ]

        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

    }
  }
  */

  group "kuma" {

    network {
      port "http" {
        to = "3001"
      }
    }

    volume "kuma-data" {
      type            = "csi"
      read_only       = false
      source          = "nfs_kuma"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    task "kuma" {
      driver = "docker"

      service {
        name = "kuma"
        port = "http"

        tags = [
          "traefik",
          "traefik.enable=true",
          "traefik.http.routers.kuma.rule=Host(`kuma.apps.cyber.psych0si.is`) && PathPrefix(`/`)",
          "traefik.http.routers.kuma.entrypoints=http,https"
        ]
      }

      volume_mount {
        volume      = "kuma-data"
        destination = "/app/data"
        read_only   = false
      }

      config {
        image = "louislam/uptime-kuma:1"
        ports = ["http"]
      }
    }
  }

}