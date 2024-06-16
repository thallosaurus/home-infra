job "fileserver" {
  type = "service"
  group "samba" {
    constraint {
      attribute = "${node.unique.name}"
      value     = "fileserver"
    }
    network {
      port "smb" {
        to     = 445
        static = 445
      }
    }

    service {
      name = "samba"
      port = "smb"

      check {
        name     = "Smb Check"
        type     = "tcp"
        protocol = "smb"
        interval = "10s"
        timeout  = "2s"
      }
    }

    volume "fs" {
      type      = "host"
      read_only = false
      source    = "samba-fs"
    }

    task "samba" {
      driver = "docker"

      template {
        destination = "smb.conf"
        data        = file("./samba/smb.conf")
      }

      env {
        USER = "user"
      }

      template {
        destination = "${NOMAD_SECRETS_DIR}/env.vars"
        env         = true
        data        = <<EOF
{{- with nomadVar "nomad/jobs" -}}
PASS={{ .root_password }}
{{- end -}}
EOF
      }

      volume_mount {
        volume      = "fs"
        destination = "/mnt"
        read_only   = false
      }

      config {
        image = "dockurr/samba"
        ports = ["smb"]

        mount {
          type   = "bind"
          target = "/etc/samba/smb.conf"
          source = "smb.conf"
        }
      }
    }
  }

  group "minio" {
    network {
      port "http" {
        to = "9000"
      }

      port "console" {}
    }

    service {
      name = "minio"
      port = "http"
      tags = [
        "traefik",
        "traefik.enable=true",
        "traefik.http.routers.minio-console.rule=Host(`minio.apps.cyber.psych0si.is`)",
        "traefik.http.routers.minio-console.service=minio-console",
        "traefik.http.services.minio-console.loadbalancer.server.port=${NOMAD_PORT_console}"
      ]

      check {
        name     = "Minio Check"
        path     = "/minio/health/live"
        type     = "http"
        protocol = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }

    service {
      name = "minio-dashboard"
      port = "console"
      tags = [
        "traefik",
        "traefik.enable=true",
        "traefik.http.routers.minio-s3.rule=Host(`*.s3.apps.cyber.psych0si.is`)",
        "traefik.http.routers.minio-s3.service=minio-s3",
        "traefik.http.services.minio-s3.loadbalancer.server.port=${NOMAD_PORT_http}",
      ]
      check {
        name     = "Minio Dashboard Check"
        #path     = "/"
        type     = "tcp"
        #protocol = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }

    volume "data" {
      type      = "host"
      read_only = false
      source    = "minio-data"
    }

    task "minio" {
      driver = "docker"

      volume_mount {
        volume      = "data"
        destination = "/data"
        read_only   = false
      }

      env {
        MINIO_ROOT_USER = "akasha"
      }

      template {
        destination = "${NOMAD_SECRETS_DIR}/env.vars"
        env         = true
        data        = <<EOF
{{- with nomadVar "nomad/jobs" -}}
MINIO_ROOT_PASSWORD={{ .root_password }}
{{- end -}}
EOF
      }

      config {
        image = "quay.io/minio/minio"
        ports = ["http", "console"]
        args  = ["server", "/data", "--console-address", ":${NOMAD_PORT_console}"]
      }

    }
  }
}