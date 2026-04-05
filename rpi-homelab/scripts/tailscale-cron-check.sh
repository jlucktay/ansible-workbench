#!/usr/bin/env bash
set -euo pipefail

### tailscale-cron-check.sh looks at Tailscale status and if either (1) Tailscale is down, or (2) the exit node is
### offline, stops the Transmission daemon/service.

tailscale_status_json=$(tailscale status --json)

backend_state=$(jq --raw-output .BackendState <<< "$tailscale_status_json")
exit_node_online=$(jq --raw-output .ExitNodeStatus.Online <<< "$tailscale_status_json")

if [[ $backend_state != "Running" ]] || [[ $exit_node_online != "true" ]]; then
  systemctl --quiet stop transmission-daemon.service
elif ! systemctl --quiet is-active transmission-daemon.service; then
  systemctl --quiet start transmission-daemon.service
fi
