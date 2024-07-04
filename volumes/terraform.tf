data "nomad_plugin" "nfs" {
  plugin_id        = "nfs"
  wait_for_healthy = true
}