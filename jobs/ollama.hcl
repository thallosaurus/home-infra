job "ollama" {
  group "ollama" {
    count = 0
    constraint {
      attribute = "${node.unique.name}"
      value     = "rastaman"
    }
    network {
      port "api" {
        to     = "11434"
        static = "11434"
      }
    }

    volume "data" {
      type            = "csi"
      read_only       = false
      source          = "nfs_ollama"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    service {
      name = "ollama"
      port = "api"
    }
    task "ollama" {
      driver = "docker"

      resources {
        memory = 1024
      }

      volume_mount {
        volume      = "data"
        destination = "/root/.ollama"
        read_only   = false
      }

      config {
        image = "ollama/ollama"
        ports = ["api"]
      }
    }
  }

  group "webui" {
    count = 0
    constraint {
      attribute = "${node.unique.name}"
      value     = "pi4"
    }

    network {
      port "http" {
        to = "8080"
      }
    }

    volume "data" {
      type            = "csi"
      read_only       = false
      source          = "nfs_ollama_webui"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    task "webui" {
      resources {
        memory = 1024
      }

      driver = "docker"
      env {
        OLLAMA_BASE_URL = "http://ollama.service.consul:11434"
      }

      #      template {
      #        data = <<EOH
      #{{ range nomadService "ollama" }}
      #OLLAMA_BASE_URL=http://{{ .Address }}:{{ .Port }}
      #{{ end }}
      #        EOH

      #        destination = "local/host.env"

      #        env = true
      #      }

      volume_mount {
        volume      = "data"
        destination = "/app/backend/data"
        read_only   = false
      }

      config {
        # docker run -d -p 3000:8080 -e OLLAMA_BASE_URL=https://example.com -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main
        image = "ghcr.io/open-webui/open-webui:main"
        ports = ["http"]
      }
    }
  }
}