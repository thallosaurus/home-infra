job "minecraft" {
  type = "service"

  group "mc" {
    constraint {
      attribute = "${node.unique.name}"
      value     = "rastaman"
    }

    network {
      mode = "bridge"
      port "minecraft" {
        to     = "25565"
        static = "25565"
      }

      port "rcon" {
        to = "25575"
        static = "25575"
      }
    }

    service {
      name = "minecraft"
      port = "minecraft"

      #check {
      #  name     = "Minecraft Check"
      #  type     = "tcp"
      #  interval = "10s"
      #  timeout  = "2s"
      #}
    }

    volume "data" {
      type            = "host"
      read_only       = false
      source          = "minecraft-data"
      #attachment_mode = "file-system"
      #access_mode     = "multi-node-multi-writer"
    }

    task "minecraft" {
      driver = "docker"

      resources {
        memory = 2048
      }

      volume_mount {
        volume      = "data"
        destination = "/data"
        read_only   = false
      }

      env {
        EULA = "true"
        CREATE_CONSOLE_IN_PIPE = "true"
      }

      config {
        image = "itzg/minecraft-server"
        ports = ["minecraft", "rcon"]
        interactive = true
      }
    }
  }
}