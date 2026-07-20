# h2: Hetzner auction server

Recurring purchase research: picking a dedicated server (hostname "h2") from the
Hetzner server auction (`stores.hetzner`), scored by CPU mark, disk layout (NVMe/total
storage thresholds), datacenter (HEL1 preferred), and price.

This directory accumulates the whole 2023–2026 run of sessions, predating
the purchases/ layout: `cache_YYYY_MM_DD/` are dated cache snapshots from
each session (the plain `cache/` is the latest), and the `<epoch>.txt` files
are saved run outputs (the filename is the run's Unix timestamp).
