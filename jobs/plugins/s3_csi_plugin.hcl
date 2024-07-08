job "plugin-s3" {
  datacenters = ["dc1"]

  # you can run node plugins as service jobs as well, but running
  # as a system job ensures all nodes in the DC have a copy.
  type = "system"

  # only one plugin of a given type and ID should be deployed on
  # any given client node
  constraint {
    operator = "distinct_hosts"
    value = true
  }

  group "nodes" {
    task "plugin" {
      driver = "docker"

    // if not specified, it defaults to 300MB of memory for the mount. Most of the mounters use memory to cache things, for example, rclone is 15 MB (default) per file open, if you attempt to open a larger set of files, you get oomkilled.
    resources {
        memory = 300
    }

      config {
          //The packaged version of goofys in rc.2 appears to not work?
          // ctrox/csi-s3 doesnt support arm for raspi
        image = "ghcr.io/thallosaurus/csi-s3:latest"

        args = [
            "--endpoint=unix:///csi/csi.sock",
            "--nodeid=${node.unique.name}",
            "--v=4",
        ]


        # all CSI node plugins will need to run as privileged tasks
        # so they can mount volumes to the host. controller plugins
        # do not need to be privileged.
        privileged = true
      }

      csi_plugin {
        id        = "s3"
        type      = "node"
        mount_dir = "/csi"  # this path /csi matches the --endpoint
                            # argument for the container
      }
    }
  }
}