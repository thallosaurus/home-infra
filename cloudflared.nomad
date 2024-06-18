job "cloudflare" {
  group "cld" {
    constraint {
      attribute = "${node.unique.name}"
      value     = "snappy"
    }
    network {
      dns {
        servers = [
          "10.0.0.1"
        ]
      }
    }
    task "cloudflared" {
      driver = "docker"
      template {
        destination = "${NOMAD_SECRETS_DIR}/env.vars"
        env         = true
        data        = <<EOF
{{- with nomadVar "nomad/jobs/cloudflare" -}}
TUNNEL_TOKEN={{ .token }}
{{- end -}}
EOF
      }

      config {
        image = "cloudflare/cloudflared:latest"
        args  = ["tunnel", "--no-autoupdate", "run"]
      }
    }
  }
}