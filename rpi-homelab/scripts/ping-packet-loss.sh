#!/usr/bin/env bash
set -euo pipefail

### ping-packet-loss.sh will, at regular intervals, send out pings in rapid succession, and log how many packets (if
### any) were lost.

PPL_DATE=$(TZ=UTC date +%Y%m%d)
PPL_LOG_FILE=/var/log/ping_packet_loss/ppl.$PPL_DATE.log

#  -A
#      Adaptive ping. Interpacket interval adapts to round-trip time, so that effectively not more than one (or more,
#      if preload is set) unanswered probe is present in the network. Minimal interval is 200msec unless super-user. On
#      networks with low RTT this mode is essentially equivalent to flood mode.
#  -n
#      Numeric output only. No attempt will be made to lookup symbolic names for host addresses.
#  -q
#      Quiet output. Nothing is displayed except the summary lines at startup time and when finished.
#  -w deadline
#      Specify a timeout, in seconds, before ping exits regardless of how many packets have been sent or received. In
#      this case ping does not stop after count packet are sent, it waits either for deadline expire or until count
#      probes are answered or for some error notification from network.
PPL_OUTPUT=$(ping -A -n -q -w 30 google.com |& awk '/packet loss/ { print $6 }')

# RFC3339
PPL_TIMESTAMP=$(TZ=UTC date +%Y-%m-%dT%H:%M:%SZ)

printf '%s: %s\n' "$PPL_TIMESTAMP" "$PPL_OUTPUT" >> "$PPL_LOG_FILE"
