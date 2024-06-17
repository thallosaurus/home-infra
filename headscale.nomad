job "vpn" {
  group "connector" {
    network {
      port "http" {
        to = "8080"
        static = "9876"
      }
    }
    service {
      name = "headscale"
      port = "http"
      tags = [
        "traefik",
        "traefik.enable=true",
        "traefik.http.routers.headscale.rule=Host(`headscale.apps.cyber.psych0si.is`) && PathPrefix(`/`)",
        "traefik.http.routers.headscale.entrypoints=http,public",
      ]
    }

    task "headscale" {
      driver = "docker"

      template {
        destination = "local/config.yaml"
        data        = file("./headscale/config.yml")
      }

      config {
        image = "headscale/headscale:0.23.0-alpha12"
        args  = ["serve"]
        ports = ["http"]
        mount {
          type     = "bind"
          source   = "local/config.yaml"
          target   = "/etc/headscale/config.yaml"
          readonly = true
        }
      }

    }
  }
}