job "gitea" {
  type = "service"

  group "gitea" {
    network {
      port "http" {
        to = "3000"
        static = "3456"
      }
    }

    service {
      name = "gitea"
      port = "http"
      tags = [
        "traefik",
        "traefik.enable=true",
        "traefik.http.routers.gitea.rule=Host(`gitea.apps.cyber.psych0si.is`) && PathPrefix(`/`)",
        #"traefik.http.routers.gitea.service=api@internal",
        "traefik.http.routers.gitea.entrypoints=http",
      ]
      #provider = "nomad"

      check {
        name     = "Gitea Frontend Check"
        path     = "/api/healthz"
        type     = "http"
        protocol = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }

    volume "data" {
      type      = "host"
      read_only = false
      source    = "gitea-data"
    }

    task "gitea" {
      driver = "docker"

      volume_mount {
        volume      = "data"
        destination = "/data"
        read_only   = false
      }

      config {
        image = "gitea/gitea"
        ports = ["http"]
      }
    }
  }
}