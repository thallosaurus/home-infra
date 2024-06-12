job "dhcp" {
  group "kea" {
    task "kea" {
      driver = "raw_exec"
      config {
        command = "/usr/sbin/kea-dhcp4"
        args    = ["-d", "-c", "/etc/kea/kea-dhcp4.conf"]
        unveil  = ["r:/etc/kea/kea-dhcp4.conf"]
      }

      template {
        destination = "/etc/kea/kea-dhcp4.conf"
        data        = file("./kea/dhcp4.conf")
      }
    }
  }
}