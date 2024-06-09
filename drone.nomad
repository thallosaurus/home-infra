job "drone" {
  type = "service"

  group "drone" {
    network {
      port "http" {
        to = "3000"
      }
    }

    task "drone" {
      driver = "docker"

      config {
        ports = ["http"]
        image = "harness/gitness"

        #volumes = [
        #  "/var/run/docker.sock:/var/run/docker.sock"
        #]

        #mounts = [
        #  {
        #    type = "bind"
        #    target = "/var/run/docker.sock"
        #    source = "/var/run/docker.sock"
        #    readonly = false
        #  }
        #]

      }
    }
  }
}