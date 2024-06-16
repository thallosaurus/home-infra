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

    task "homeassistant_core" {
      driver = "docker"

      volume_mount {
        volume      = "data"
        destination = "/config"
        read_only   = false
      }

      config {
        hostname     = "hostname"
        force_pull   = true
        image        = "homeassistant/home-assistant:stable"
        network_mode = "host"
        privileged   = true
        volumes = [
          #            "/nfs/home_assistant/config:/config",
          #            "/etc/localtime:/etc/localtime:ro"
          #"/var/dbus:/var/dbus"
        ]
        port_map {
          homeassistant_core = 8123
        }
      }
      resources {
        cpu    = 800 # 500 MHz
        memory = 512 # 512 MB
        network {
          mbits = 300
          port "homeassistant_core" { static = 8123 }
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