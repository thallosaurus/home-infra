job "demo-webapp" {
  datacenters = ["dc1"]

  group "nginx" {
    count = 1

    #constraint {
    #  attribute = "${node.unique.name}"
    #  value     = "snappy"
    #}

    network {
      mode = "bridge"
      port "http" {
        to = "80"
      }
    }

    service {
      name = "nginx"
      port = "http"
    }

    task "nginx" {
      driver = "docker"

      config {
        image = "nginx"

        ports = ["http"]
      }
    }
  }
}