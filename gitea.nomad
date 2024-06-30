job "gitea" {
  type = "service"

  group "gitea" {
    network {
      dns {
        servers = [
          "10.0.0.1",
          "10.0.0.254",
          "8.8.8.8",
        ]
      }
      port "http" {
        to     = "3000"
        static = "3456"
      }

      port "ssh" {
        to     = "22"
        static = "2222"
      }
    }

    service {
      name = "gitea"
      port = "http"
      tags = [
        "traefik",
        "traefik.enable=true",
        "traefik.http.routers.gitea.rule=(Host(`gitea.apps.cyber.psych0si.is`) || Host(`git.cyber.psych0si.is`)) && PathPrefix(`/`)",
        "traefik.http.routers.gitea.entrypoints=http,public",
      ]
      #provider = "nomad"

      check {
        name     = "Gitea Frontend Check"
        #path     = "/api/healthz"
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
      source          = "nfs_gitea"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    task "gitea" {
      driver = "docker"

      volume_mount {
        volume      = "data"
        destination = "/data"
        read_only   = false
      }

      config {
        image      = "gitea/gitea"
        ports      = ["http"]
        privileged = true
        #        mount {
        #          type     = "bind"
        #          source   = "local/app.ini"
        #          target   = "/data/gitea/conf/app.ini"
        #          readonly = true
        #        }
      }
    }

    task "runner" {
      driver = "docker"

      template {
        env         = true
        destination = "secrets/runner_secret.env"

        data = <<EOH
{{- with nomadVar "nomad/jobs" -}}
CONFIG_FILE=/config.yaml
GITEA_INSTANCE_URL=http://gitea.apps.cyber.psych0si.is
GITEA_RUNNER_NAME=test
GITEA_RUNNER_REGISTRATION_TOKEN={{ .gitea_token01 }}
{{- end -}}
        EOH
      }

      template {
        destination = "tmp/config.yaml"
        data        = file("./runner/config.yaml")
      }

      config {
        image = "gitea/act_runner"
        mount {
          type = "bind"

          source   = "/var/run/docker.sock"
          target   = "/var/run/docker.sock"
          readonly = false
        }
        mount {
          type = "bind"

          source   = "tmp/config.yaml"
          target   = "/config.yaml"
          readonly = false
        }
      }
    }
  }
}