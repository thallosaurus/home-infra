terraform {
  required_providers {
    nomad = {
      source  = "hashicorp/nomad"
      version = "2.3.0"
    }
  }
  backend "consul" {
    address = "consul.service.consul:8500"
    scheme  = "http"
    path    = "terraform/state"
  }
}

#module "volumes" {
#  source = "./volumes"
#}

provider "nomad" {
  address = "http://nomad.service.consul:4646"
}