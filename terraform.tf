terraform {
  backend "consul" {
    address = "10.0.0.1:8500"
    scheme  = "http"
    path    = "infra"
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
    vault = {
      source = "hashicorp/vault"
      version = "4.2.0"
    }
  }
}

provider "docker" {
  host = "tcp://10.0.0.1:2375"
}

# Configure the Consul provider
provider "consul" {
  address    = "10.0.0.1:8500"
  datacenter = "dc1"
}

provider "nomad" {
  address = "http://10.0.0.1:4646"
  region  = "dc1"
}
