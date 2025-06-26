#!/bin/bash

set -euo pipefail

DOMAIN="${1:-itdog.info}"

if ! command -v dig &> /dev/null
then
    echo "dig is not installed. Commands to install:"
    echo "Debian/Ubuntu: sudo apt install dnsutils"
    echo "OpenWrt: opkg install bind-dig"
    exit 1
fi

dns_query() {
    local protocol="$1"
    local resolver_name="$2"
    local resolver_host="$3"
    
    local result=$(dig +short +${protocol} +time=3 +tries=1 @"$resolver_host" "$DOMAIN" A 2>&1)

    if echo "$result" | grep -q "failed:\|timed out\|no servers could be reached\|connection refused"; then
        echo "  ❌ $resolver_name"
        echo "$result" | grep -E "(failed:|timed out|no servers|connection)" | sed 's/^/    /'
        return
    fi

    local ip_lines=$(echo "$result" | grep -E '^([0-9]{1,3}\.){3}[0-9]{1,3}$' || true)

    if [ -n "$ip_lines" ]; then
        echo "  ✅ $resolver_name"
    else
        echo "  ❌ $resolver_name"
        echo "$result" | grep -v '^$' | sed 's/^/    /'
    fi
}

RESOLVERS_DOH=(
    "Cloudflare:1.1.1.1"
    "Google:8.8.8.8"
    "Quad9:9.9.9.9"
    "AdGuardDNS:dns.adguard.com"
    "NextDNS:dns.nextdns.io"
)

RESOLVERS_DOT=(
    "Cloudflare:1.1.1.1"
    "Google:8.8.8.8"
    "Quad9:9.9.9.9"
    "AdGuardDNS:dns.adguard.com"
    "NextDNS:dns.nextdns.io"
)

echo "🔒 DNS over HTTPS (DoH)"

for resolver in "${RESOLVERS_DOH[@]}"; do
    name=${resolver%%:*}
    host=${resolver#*:}
    dns_query "https" "$name" "$host"
done

echo ""
echo "🔒 DNS over TLS (DoT)"

for resolver in "${RESOLVERS_DOT[@]}"; do
    name=${resolver%%:*}
    host=${resolver#*:}
    dns_query "tls" "$name" "$host"
done
