job "monitor" {
  group "prometheus" {
    network {
      mode = "bridge"
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
        destination = "local/prometheus.yml"
        data        = <<EOH
global:
  scrape_interval:     15s # By default, scrape targets every 15 seconds.

  # Attach these labels to any time series or alerts when communicating with
  # external systems (federation, remote storage, Alertmanager).
  external_labels:
    monitor: 'codelab-monitor'

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

    # Legacy api password
    #params:
    #  api_password: ['PASSWORD']
    
    authorization:
    # Long-Lived Access Token
    {{- with nomadVar "nomad/jobs/monitor" -}}
      credentials: "{{ .hoass_prom_key }}"
    {{- end -}}

    scheme: http
    static_configs:
      - targets: ['assistant.apps.cyber.psych0si.is']
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

        image = "prom/prometheus"
        ports = ["http"]
        args  = ["--config.file=/etc/prometheus/prometheus.yml"]
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
    }
  }

  group "influxdb" {
    network {
      mode = "bridge"
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

}