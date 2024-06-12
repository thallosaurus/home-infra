job "minio" {
  type = "service"

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
        "traefik.http.services.minio-console.loadbalancer.server.port=${NOMAD_PORT_console}",

        "traefik.http.routers.minio-s3.rule=Host(`s3.apps.cyber.psych0si.is`)",
        "traefik.http.routers.minio-s3.service=minio-s3",
        "traefik.http.services.minio-s3.loadbalancer.server.port=${NOMAD_PORT_http}",
      ]
      #provider = "nomad"

      check {
        name     = "Minio Check"
        path     = "/minio/health/live"
        type     = "http"
        protocol = "http"
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
        MINIO_ROOT_USER     = "akasha"
        MINIO_ROOT_PASSWORD = "testtest123"
      }

      config {
        image = "quay.io/minio/minio"
        ports = ["http", "console"]
        args  = ["server", "/data", "--console-address", ":${NOMAD_PORT_console}"]
      }

    }
  }
}