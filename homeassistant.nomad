job "homeassistant" {
  type = "service"
  update {
    max_parallel      = 1
    min_healthy_time  = "10s"
    healthy_deadline  = "6m"
    progress_deadline = "10m"
    auto_revert       = false
    canary            = 0
  }
  migrate {
    max_parallel     = 1
    health_check     = "checks"
    min_healthy_time = "15s"
    healthy_deadline = "10m"
  }
  group "homeassistant" {
    count = 1
    constraint {
      attribute = "${node.unique.name}"
      value     = "pi4"
    }
    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    volume "data" {
      type      = "host"
      read_only = false
      source    = "homeassistant-data"
    }

    volume "hoass-data" {
      type            = "csi"
      read_only       = false
      source          = "nfs_hoass"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    task "homeassistant_core" {
      driver = "docker"

      template {
        destination = "local/configuration.yaml"
        data        = <<EOH
# Loads default set of integrations. Do not remove.
default_config:

# Load frontend themes from the themes folder
frontend:
  themes: !include_dir_merge_named themes

automation: !include automations.yaml
script: !include scripts.yaml
scene: !include scenes.yaml

http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 10.0.0.1

prometheus:
  requires_auth: false

homekit:
  - name: HASS Bridge
    advertise_ip: "{{ env "NOMAD_IP_homekit_bridge" }}"
    port: {{ env "NOMAD_PORT_homekit_bridge" }}
        EOH
      }

      volume_mount {
        volume      = "hoass-data"
        destination = "/config"
        read_only   = false
      }



      config {
        hostname     = "hostname"
        force_pull   = true
        image        = "homeassistant/home-assistant:stable"
        network_mode = "host"
        privileged   = true
        volumes = []
        port_map {
          homeassistant_core = 8123
        }

        mount {
          type   = "bind"
          source = "local/configuration.yaml"
          target = "/config/configuration.yaml"
        }
      }
      resources {
        cpu    = 800 # 500 MHz
        memory = 512 # 512 MB
        network {
          mbits = 300
          port "homeassistant_core" { static = 8123 }
          port "avahi" { static = 5353 }
          port "homekit_bridge" {}
        }
      }
      service {
        name = "homeassistant"
        port = "homeassistant_core"

        tags = [
          "homeassistant",
          "homeautomation",
          "traefik",
          "traefik.enable=true",
          "traefik.http.routers.hoass.rule=Host(`assistant.apps.cyber.psych0si.is`) && PathPrefix(`/`)"
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