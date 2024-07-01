job "vpn" {
  group "connector" {
    count = 0
    network {
      port "http" {
        to     = "8080"
        static = "9876"
      }
    }
    service {
      name = "headscale"
      port = "http"
      tags = [
        "traefik",
        #"traefik.enable=true",
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

  group "tailscale" {
    constraint {
      attribute = "${node.unique.name}"
      value     = "snappy"
    }
    task "ts" {
      driver = "docker"

      env {
        TS_EXTRA_ARGS = "-advertise-exit-node -advertise-routes=10.0.0.0/24"
      }

      template {
        data = <<EOH
{{- with nomadVar "nomad/jobs/vpn" -}}
TS_AUTHKEY={{ .ts_authkey }}
{{- end -}}
        EOH

        destination = "${NOMAD_SECRETS_DIR}/env.vars"
        env         = true
      }

      config {
        image    = "tailscale/tailscale:latest"
        hostname = "cluster"

        mount {
          type   = "bind"
          target = "/dev/net/tun"
          source = "/dev/net/tun"
        }

        privileged = true
      }
    }
  }
}