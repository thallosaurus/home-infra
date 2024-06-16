resource "nomad_job" "traefik" {
  jobspec = file("${path.module}/traefik.nomad")

  hcl2 {
    allow_fs = true
  }
}

resource "nomad_job" "bind" {
  jobspec = file("${path.module}/bind.nomad")

  hcl2 {
    allow_fs = true
  }
}

resource "nomad_job" "cloudflared" {
  jobspec = file("${path.module}/cloudflared.nomad")

  hcl2 {
    allow_fs = true
  }
}

resource "nomad_job" "gitea" {
  jobspec = file("${path.module}/gitea.nomad")

  hcl2 {
    allow_fs = true
  }
}

resource "nomad_job" "homeassistant" {
  jobspec = file("${path.module}/homeassistant.nomad")

  hcl2 {
    allow_fs = true
  }
}

resource "nomad_job" "minecraft" {
  jobspec = file("${path.module}/minecraft.nomad")

  hcl2 {
    allow_fs = true
  }
}

resource "nomad_job" "samba" {
  jobspec = file("${path.module}/samba.nomad")

  hcl2 {
    allow_fs = true
  }
}

resource "nomad_job" "dhcp" {
  jobspec = file("${path.module}/dhcp.nomad")

  hcl2 {
    allow_fs = true
  }
}