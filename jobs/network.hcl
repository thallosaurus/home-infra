job "network" {
  type = "service"

  update {
    auto_revert  = true
    max_parallel = 3
  }

  group "dns" {
    constraint {
      attribute = "${node.unique.name}"
      value     = "snappy"
    }

    network {
      port "dns" {
        to     = "53"
        static = "53"
      }
    }

    task "bind9" {
      driver = "docker"
      template {
        destination = "tmp/named.conf.local"
        data        = <<EOH
//include "/etc/bind/zones.rfc1918";

zone "apps.cyber.psych0si.is" {
  type master;
  file "/etc/bind/zones/db.apps.cyber.psych0si.is";
};

zone "int.cyber.psych0si.is" {
  type master;
  file "/etc/bind/zones/db.int.cyber.psych0si.is";
};

zone "0.0.10.in-addr.arpa" {
  type master;
  file "/etc/bind/zones/db.0.0.10.in-addr.arpa";
};

zone "consul" IN {
  type forward;
  forward only;
  forwarders { 10.0.0.1 port 8600; };
};
        EOH
      }

      template {
        destination = "tmp/named.conf.options"
        data        = <<EOH
options {
  directory "/var/cache/bind";
  allow-query { any; };
  recursion yes;
  dnssec-validation no;
  forwarders {
    // 10.0.0.254;
    8.8.8.8;
  };
  auth-nxdomain no;
  listen-on-v6 { any; };
};
        EOH
      }

      template {
        destination = "tmp/db.0.0.10.in-addr.arpa"
        data        = file("./appdata/dns/db.0.0.10.in-addr.arpa")
      }

      template {
        destination = "tmp/db.int.cyber.psych0si.is"
        data        = file("./appdata/dns/db.int.cyber.psych0si.is")
      }

      template {
        destination = "tmp/db.apps.cyber.psych0si.is"
        data        = file("./appdata/dns/db.apps.cyber.psych0si.is")
      }

      config {
        image = "ubuntu/bind9"
        ports = ["dns"]
        mounts = [
          {
            type   = "bind"
            target = "/etc/bind/zones/db.int.cyber.psych0si.is"
            source = "tmp/db.int.cyber.psych0si.is"
          },
          {
            type   = "bind"
            target = "/etc/bind/zones/db.apps.cyber.psych0si.is"
            source = "tmp/db.apps.cyber.psych0si.is"
          },
          {
            type   = "bind"
            target = "/etc/bind/zones/db.0.0.10.in-addr.arpa"
            source = "tmp/db.0.0.10.in-addr.arpa"
          },
          {
            type   = "bind"
            target = "/etc/bind/named.conf.options"
            source = "tmp/named.conf.options"
          },
          {
            type   = "bind"
            target = "/etc/bind/named.conf.local"
            source = "tmp/named.conf.local"
          }
        ]
      }
    }
  }

  group "dhcp" {
    constraint {
      attribute = "${node.unique.name}"
      value     = "snappy"
    }

    network {
      port "dhcp1" {
        to     = "67"
        static = "67"
      }

      port "dhcp2" {
        to     = "68"
        static = "68"
      }
    }

    task "dnsmasq" {
      driver = "docker"
      template {
        destination = "tmp/dnsmasq.conf"
        data        = file("./appdata/dhcp/dnsmasq.conf")
      }

      config {
        image = "dockurr/dnsmasq"
        ports = ["dhcp1", "dhcp2"]
        privileged = true

        network_mode = "host"

        mount {
          type = "bind"
          source = "tmp/dnsmasq.conf"
          target = "/etc/dnsmasq.conf"
        }
      }
    }
  }
}