job "pihole" {
  group "pihole" {
    constraint {
      attribute = "${node.unique.name}"
      value     = "snappy"
    }

    network {
      mode = "cni/test"
      port "dns" {
        to = "53"
      }
      port "http" {
        to = "80"
      }
    }

    service {
      name = "pihole"
      port = "http"
    }
    task "pihole" {
      driver = "docker"

      template {
        destination = "secrets/admin.env"
        data        = <<EOH
{{- with nomadVar "nomad/jobs" -}}
WEBPASSWORD={{ .root_password }}
{{- end -}}
        EOH
        env         = true
      }

      config {
        image = "pihole/pihole"
        ports = ["dns", "http"]
      }
    }
  }
}