job "gitness" {
  group "gitness" {
    network {
      port "http" {
        to = "3000"
      }
    }

    service {
      name = "gitness"
      port = "http"
      tags = [
        "traefik",
        "traefik.enable=true",
        "traefik.http.routers.gitness.rule=Host(`gitness.apps.cyber.psych0si.is`) && PathPrefix(`/`)",
        "traefik.http.routers.gitness.entrypoints=http",
      ]
      #provider = "nomad"

      check {
        name     = "Gitness Frontend Check"
        path     = "/"
        type     = "http"
        protocol = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }

    volume "data" {
      type            = "csi"
      read_only       = false
      source          = "nfs_gitness"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    task "gitness" {
      driver = "docker"

      volume_mount {
        volume      = "data"
        destination = "/data"
      }

      env {
        GITNESS_URL_BASE = "http://gitness.apps.cyber.psych0si.is"
        GITNESS_URL_CONTAINER = "http://gitness.apps.cyber.psych0si.is"
        GITNESS_USER_SIGNUP_ENABLED = "false"
      }
      config {
        mount {
          type = "bind"

          source   = "/var/run/docker.sock"
          target   = "/var/run/docker.sock"
          readonly = false
        }


        image = "harness/gitness"
        ports = ["http"]
      }
    }
  }
}