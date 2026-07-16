# NIA Monitoring — endpoint stack

Reusable Compose template for Raspberry Pi exporters. One shared repo
([`docker-slice-pi`](https://github.com/picomms/docker-slice-pi)); unique `.env`
per host.

**Documentation (source of truth)** lives in the server repo:

- [Slice template](https://picomms.github.io/monitoring-nia-pi/developer/slice/)
- [Cloudflare (Grafana only)](https://picomms.github.io/monitoring-nia-pi/cloudflare/)

## Quick start

```bash
cp env.sample .env
# set HOST_ID, SPEEDTEST_APP_KEY, WP_PRIMARY_URL, WP_SECONDARY_URL
just up
just ps
```

The local Prometheus Agent scrapes this Pi plus its two Web Presenters, then
remote_writes to Cherry over **Tailscale**:

```text
http://cherry.taild08b87.ts.net:9090/api/v1/write
```

Published ports remain useful for local debug:

| Port | Service |
| --- | --- |
| `9100` | `node_exporter` |
| `9115` | `blackbox_exporter` |
| `8765` | `speedtest-tracker` (UI + `/prometheus`) |

Generate `SPEEDTEST_APP_KEY` (unique per host):

```bash
# any machine with Docker:
openssl rand -base64 32 | sed 's/^/base64:/'
```

Restrict ports with Tailscale ACLs / host firewall. Optional tunnel: set
`TUNNEL_TOKEN` and `just up-tunnel` (not required for scrapes).

## Verify locally

```bash
curl -sS http://127.0.0.1:9100/metrics | head
curl -sS http://127.0.0.1:9115/metrics | head
curl -sS http://127.0.0.1:8765/prometheus | head
just logs prometheus
```

From Cherry after remote_write:

```bash
curl --get http://localhost:9090/api/v1/query \
  --data-urlencode 'query=up{job="node_remote",instance="<HOST_ID>"}'
curl --get http://localhost:9090/api/v1/query \
  --data-urlencode 'query=bmd_wp_livestream_info{instance="<HOST_ID>"}'
```
