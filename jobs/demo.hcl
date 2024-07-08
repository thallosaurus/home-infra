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

    volume "data" {
      type            = "csi"
      read_only       = false
      source          = "test-vol"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
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

        volume_mount {
          volume = "data"
          destination = "/usr/share/nginx/html/test"
          read_only = false
        }
      }
    }
  }
}