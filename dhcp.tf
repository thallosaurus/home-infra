terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "docker" {
  host = "tcp://snappy.node.consul:2375"
}

resource "docker_image" "kea-dhcp4" {
  name = "jonasal/kea-dhcp4:2.6-alpine"
}

resource "docker_container" "kea" {
  name  = "kea-dhcp4-tf"
  image = docker_image.kea-dhcp4.image_id

  upload {
    file   = "/etc/kea/kea-dhcp4.conf"
    content = file("./kea/dhcp4.conf")
  }

  command = ["/entrypoint.sh", "-c", "/etc/kea/kea-dhcp4.conf"]
}
