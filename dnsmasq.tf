resource "docker_image" "dnsmasq" {
  name = "dockurr/dnsmasq"
}

resource "docker_container" "dnsmasq" {
  count = 1
  name  = "dnsmasq"
  image = docker_image.dnsmasq.image_id

  upload {
    file    = "/etc/dnsmasq.conf"
    content = file("./dhcp/dnsmasq.conf")
  }

  network_mode = "host"

  # nomads privileged mode didnt work
  privileged = true

  #command = ["/entrypoint.sh", "-c", "/etc/kea/kea-dhcp4.conf"]
}