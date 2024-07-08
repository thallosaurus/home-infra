job "pihole" {
  group "pihole" {
    constraint {
      attribute = "${node.unique.name}"
      value     = "pi4"
    }

    network {
      //mode = "cni/test"
      port "dns" {
        to     = "53"
        static = "53"
      }
      port "http" {
        to = "80"
      }
    }

    service {
      name = "pihole"
      port = "http"

      tags = [
        "traefik",
        "traefik.enable=true",
        "traefik.http.routers.pihole.rule=Host(`pihole.apps.cyber.psych0si.is`) && PathPrefix(`/`)",
        "traefik.http.routers.pihole.entrypoints=http"
      ]
    }

    volume "pihole-data" {
      type            = "csi"
      read_only       = false
      source          = "nfs_pihole"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
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

      volume_mount {
        volume      = "pihole-data"
        destination = "/etc/pihole"
        read_only   = false
      }

      config {
        image = "pihole/pihole"
        ports = ["dns", "http"]
      }
    }
  }
}