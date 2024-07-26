job "traefik" {
  type = "service"

  group "traefik" {
    count = 1
    #constraint {
    #  attribute = "${node.unique.name}"
    #  value     = "snappy"
    #}

    constraint {
      operator = "distinct_hosts"
      value    = "true"
    }
    network {
      port "http" {
        to     = "80"
        static = "80"
      }

      port "https" {
        to     = "443"
        static = "443"
      }

      port "public" {
        to     = "8081"
        static = "8081"
      }

      port "dashboard" {
        to = "8080"
      }
    }

    service {
      name = "dashboard"
      port = "dashboard"
      tags = [
        "traefik",
        "traefik.enable=true",
        "traefik.http.routers.traefik-dashboard.rule=Host(`traefik-dashboard.apps.cyber.psych0si.is`)",
        "traefik.http.routers.traefik-dashboard.entrypoints=http"
      ]
      #provider = "nomad"

      #check {
      #  name     = "Traefik Check"
      #  path     = "/dashboard/"
      #  type     = "http"
      #  protocol = "http"
      #  interval = "10s"
      #  timeout  = "2s"
      #}
    }

    service {
      name = "traefik"
      port = "http"
    }

    task "traefik" {
      driver = "docker"

      config {
        image = "traefik:v3.0"
        ports = ["http", "https", "dashboard", "public"]
        args  = ["--configFile", "/local/Traefik.yml"]
      }

      resources {
        cpu = 1024
      }

      template {
        destination = "/local/dynamic.yml"
        data        = file("./appdata/traefik/dynamic.yml")
      }

      template {
        destination = "/local/Traefik.yml"
        data        = file("./appdata/traefik/traefik.yml")
      }

      /*volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
      ]*/

    }
  }
}