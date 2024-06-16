job "fs" {

group "swfs" {
    constraint {
      attribute = "${node.unique.name}"
      value     = "fileserver"
    }
    network {
      port "api" {
        to = 8333
      }
    }
    task "seaweedfs" {
      driver = "docker"

      config {
        image = "chrislusf/seaweedfs"

        ports = ["api"]

        args = ["server", "-s3"]
      }
    }
  }
}