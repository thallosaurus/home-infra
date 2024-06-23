job "test" {
  group "test" {
    network {
      port "http" {
        to = "80"
      }
    }
    task "test" {
      driver = "docker"
      template {
        data = file("./homepage/index.tpl")

        destination = "local/test.html"
      }
      config {
        image = "nginx"
        ports = ["http"]

        mount {
            type = "bind"
            source = "local/test.html"
            target = "/usr/share/nginx/html/index.html"
        }
      }
    }
  }
}