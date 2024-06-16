resource "docker_image" "kea-dhcp4" {
  name = "smailkoz/kea-dhcp"
}

resource "docker_container" "kea" {
  count = 0
  name  = "kea-dhcp4-tf"
  image = docker_image.kea-dhcp4.image_id

  upload {
    file    = "/etc/kea/kea-dhcp4.conf"
    content = file("./kea/dhcp4.conf")
  }

  network_mode = "host"

  command = ["/entrypoint.sh", "-c", "/etc/kea/kea-dhcp4.conf"]
}