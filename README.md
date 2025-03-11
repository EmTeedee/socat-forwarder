# socat Forwarder

Minimal forwarding of IPv4 traffic (TCP/UDP) to IPv6.

## Installation

The script/unit file assume configuration files in `/etc/socat-forwarder` and
the `socat-forwarder.sh` script to be located/linked in `/usr/local/sbin`

To enable the serivce, use e.g. `systemctl enable --now socat-forwarder@example`

## Configuration

### `UPDATE_INTERVAL`

How often the source for ipv6 address information is checked for changes in seconds (default: 60)

### `IPV6_HOST`

If set, do a AAAA lookup of this address to check for IPv6 address to forward to.

### `IPV6_FILE`

If set, read this file regularly to get the IPv6 address to forward to.

### `TCP_PORTS`, `UDP_PORTS`

Array of ports to forward
