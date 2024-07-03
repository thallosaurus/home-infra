# Domains
The Network exposes the following DNS Zones:
1. .apps.cyber.psych0si.is
2. .int.cyber.psych0si.is

Each Zone gets manually assigned by the admin with the corresponding zone configs found in the `bind/` folder. Because `.int.<...>` is mapped to a physical network it also has a reverse dns zone. Most of them are just CNAMES for traefik reverse proxy tho.