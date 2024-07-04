job "vpn" {
  group "tailscale" {
    #constraint {
    #  attribute = "${node.unique.name}"
    #  value     = "snappy"
    #}
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