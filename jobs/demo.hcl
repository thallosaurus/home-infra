job "demo-webapp" {
  datacenters = ["dc1"]

  group "nginx" {
    count = 1

    #constraint {
    #  attribute = "${node.unique.name}"
    #  value     = "snappy"
    #}

    network {
      mode = "bridge"
      port "http" {
        to = "80"
      }
    }

    service {
      name = "nginx"
      port = "http"
    }

    task "nginx" {
      driver = "docker"

      template {
        destination = "local/index.html"
        data        = <<EOH
        <h1>Hello</h1>
{{ range service "minecraft" -}}
<p>{{ .Address }}:{{ .Port }};</p>
{{ end }}
  EOH
      }

      config {
        image = "nginx"

        ports = ["http"]

        mount {
          type   = "bind"
          source = "local/index.html"
          target = "/usr/share/nginx/html/index.html"
        }
      }
    }
  }
}