# ghcr.io/alexta69/metube
job "metube" {
  group "metube" {
    constraint {
      attribute = "${node.unique.name}"
      value     = "pi4"
    }
    network {
      port "http" {
        to = "8081"
      }
    }

    volume "data" {
      type            = "csi"
      read_only       = false
      source          = "nfs_ytdl"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    task "metube" {
      driver = "docker"

      service {
        name = "metube"
        port = "http"

        tags = [
          "traefik",
          "traefik.enable=true",
          "traefik.http.routers.metube.rule=Host(`metube.apps.cyber.psych0si.is`) && PathPrefix(`/`)",
          "traefik.http.routers.metube.entrypoints=http,public"
        ]
      }

      volume_mount {
        volume      = "data"
        destination = "/downloads"
        read_only   = false
      }

      config {
        image = "ghcr.io/alexta69/metube"
        ports = ["http"]
      }
    }
  }
}