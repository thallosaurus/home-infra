job "tor" {
  group "tor" {
    constraint {
      attribute = "${node.unique.name}"
      value     = "pi4"
    }
    network {
      port "http" {
        to     = "8118"
        static = "8118"
      }

      port "socks" {
        to     = "9050"
        static = "9050"
      }
    }

    service {
      name = "tor"
      port = "socks"
    }

    task "tor" {
      driver = "docker"

      config {
        image = "dperson/torproxy"
        ports = ["http", "socks"]
      }
    }
  }
}