job "minecraft" {
  type = "service"

  group "mc" {
    network {
      mode = "bridge"
      port "minecraft" {
        to     = "25565"
        static = "25565"
      }
    }

    service {
      name = "minecraft"
      port = "minecraft"

      check {
        name     = "Minecraft Check"
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    volume "data" {
      type      = "host"
      read_only = false
      source    = "minecraft-data"
    }

    task "minecraft" {
      driver = "docker"

      resources {
        memory = 1024
      }

      volume_mount {
        volume      = "data"
        destination = "/data"
        read_only   = false
      }

      env {
        EULA = "true"
      }

      config {
        image = "itzg/minecraft-server"
        ports = ["minecraft"]
      }
    }
  }
}