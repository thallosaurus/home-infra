terraform {
  required_providers {
    nomad = {
      source  = "hashicorp/nomad"
      version = "2.3.0"
    }
  }
  backend "consul" {
    address = "10.0.0.1:8500"
    scheme  = "http"
    path    = "terraform/state"
  }
}

#module "volumes" {
#  source = "./volumes"
#}

provider "nomad" {
  address = "http://10.0.0.1:4646"
}