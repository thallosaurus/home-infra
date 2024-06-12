job "dhcp" {
  group "kea" {
    count = 0
    constraint {
      attribute = "${node.unique.name}"
      value     = "snappy"
    }

    network {
      mode = "host"
    }

    task "kea" {
      driver = "docker"
      template {
        destination = "dhcp4.conf"
        data        = file("./kea/dhcp4.conf")
      }

      config {
        image = "jonasal/kea-dhcp4:2.6-alpine"

        network_mode = "host"

        mounts = [
          {
            type   = "bind"
            target = "/etc/kea/kea-dhcp4.conf"
            source = "dhcp4.conf"
          }
        ]

        args = [
          "-c", "/etc/kea/kea-dhcp4.conf"
        ]
      }
    }
  }
}