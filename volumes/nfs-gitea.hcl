type = "csi"
id = "nfs_gitea"
name = "nfs_gitea"
plugin_id = "nfs"

capability {
  access_mode = "multi-node-multi-writer"
  attachment_mode = "file-system"
}

capability {
  access_mode = "single-node-writer"
  attachment_mode = "file-system"
}

context {
  server = "10.0.0.3"
  share = "/mnt/nfs/gitea"
}

mount_options {
  fs_type = "nfs"
  mount_flags = [ "nolock" ]
}