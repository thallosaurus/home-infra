terraform {
  backend "consul" {
    address = "10.0.0.1:8500"
    scheme  = "http"
    path    = "test/tf"
  }
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "2.14.0"
    }

  }
}

provider "docker" {
  host = "tcp://snappy.node.consul:2375"
}

# Configure the Consul provider
provider "consul" {
  address    = "consul.service.consul:8500"
  datacenter = "dc1"

  # SecretID from the previous step
  #token      = "YOUR_BOOTSTRAP_TOKEN_HERE"
}

resource "docker_image" "kea-dhcp4" {
  name = "jonasal/kea-dhcp4:2.6-alpine"
}

resource "docker_container" "kea" {
  count = 0
  name  = "kea-dhcp4-tf"
  image = docker_image.kea-dhcp4.image_id

  upload {
    file    = "/etc/kea/kea-dhcp4.conf"
    content = file("./kea/dhcp4.conf")
  }

  command = ["/entrypoint.sh", "-c", "/etc/kea/kea-dhcp4.conf"]
}
