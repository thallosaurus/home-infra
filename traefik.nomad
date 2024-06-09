job "traefik" {
  type = "service"

  group "traefik" {
    constraint {
      attribute = "${node.unique.name}"
      value     = "snappy"
    }
    network {
      port "http" {
        to     = "80"
        static = "80"
      }

      port "dashboard" {
        to = "8080"
      }
    }

    service {
      name = "traefik"
      port = "http"
    }

    task "traefik" {
      driver = "docker"

      config {
        image = "traefik:v3.0"
        ports = ["http", "dashboard"]
        args  = ["--configFile", "/local/Traefik.yml"]
      }

      #template {
      #  destination = "/local/dynamic.yml"
      #  source      = "traefik/dynamic.yml"
      #}

      template {
        destination = "/local/Traefik.yml"
        data        = file("./traefik/traefik.yml")
      }

      /*volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
      ]*/

    }
  }
}