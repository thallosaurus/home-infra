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

  group "swfs" {
    constraint {
      attribute = "${node.unique.name}"
      value     = "fileserver"
    }
    network {
      port "api" {
        to = 8333
      }
    }

    service {
      name = "swfs"
      port = "api"
      tags = [
        "traefik",
        "traefik.enable=true",
        "traefik.http.routers.swfs.rule=Host(`swfs.apps.cyber.psych0si.is`)",
        #        "traefik.http.routers.swfs.service=minio-console",
        "traefik.http.services.swfs.loadbalancer.server.port=${NOMAD_PORT_api}"

        #"traefik.http.routers.minio-s3.rule=Host(`s3.apps.cyber.psych0si.is`)",
        #"traefik.http.routers.minio-s3.service=minio-s3",
        #"traefik.http.services.minio-s3.loadbalancer.server.port=${NOMAD_PORT_http}",
      ]
      #provider = "nomad"

      #check {
      #  name     = "Minio Check"
      #  path     = "/minio/health/live"
      #  type     = "http"
      #  protocol = "http"
      #  interval = "10s"
      #  timeout  = "2s"
      #}
    }

    task "seaweedfs" {
      driver = "docker"

      config {
        image = "chrislusf/seaweedfs"

        ports = ["api"]

        args = ["server", "-s3"]
      }
    }
  }
}