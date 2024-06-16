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

      template {
        destination = "/etc/dnsmasq.conf"
        data        = file("./dhcp/dnsmasq.conf")
      }

      config {
        image = "dockurr/dnsmasq"

        network_mode = "host"

        #args = [
        #  "-c", "/etc/kea/kea-dhcp4.conf"
        #]

  privileged = true
      }
    }
  }
}