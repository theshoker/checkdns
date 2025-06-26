#!/bin/sh

set -eu

DOMAIN="${1:-itdog.info}"

if ! dig -v >/dev/null 2>&1; then
    echo "dig is not installed. Commands to install:"
    echo "Debian/Ubuntu: sudo apt install dnsutils"
    echo "OpenWrt: opkg install bind-dig"
    exit 1
fi

dns_query() {
    protocol="$1"
    resolver_name="$2"
    resolver_host="$3"
    
    result=$(dig +${protocol} +time=3 +tries=1 @"$resolver_host" "$DOMAIN" A 2>&1)

    if echo "$result" | grep -q "failed:\|timed out\|no servers could be reached\|connection refused\|host unreachable"; then
        echo "  ❌ $resolver_name"
        echo "$result" | grep -E "(failed:|timed out|no servers|connection|unreachable)" | sed 's/^/    /'
        return
    fi

    ip_lines=$(echo "$result" | grep -E '^([0-9]{1,3}\.){3}[0-9]{1,3}$' || true)

    query_time=$(echo "$result" | grep "Query time:" | sed 's/.*Query time: \([0-9]*\) msec.*/\1/')

    ip_lines=$(echo "$result" | grep -A 10 "ANSWER SECTION:" | grep -E "IN[[:space:]]+A[[:space:]]+([0-9]{1,3}\.){3}[0-9]{1,3}" || echo "")

    if [ -n "$ip_lines" ]; then
        if [ -n "$query_time" ]; then
            echo "  ✅ $resolver_name ($query_time ms)"
        else
            echo "  ✅ $resolver_name"
        fi
    else
        if [ -n "$query_time" ]; then
            echo "  ❌ $resolver_name ($query_time ms)"
        else
            echo "  ❌ $resolver_name"
        fi
        echo "$result" | grep -v '^$' | grep -v '^;' | sed 's/^/    /'
    fi
}

RESOLVERS_DOH="Cloudflare:1.1.1.1 Google:8.8.8.8 Quad9:9.9.9.9 AdGuardDNS:dns.adguard-dns.com NextDNS:dns.nextdns.io"

RESOLVERS_DOT="Cloudflare:1.1.1.1 Google:8.8.8.8 Quad9:9.9.9.9 AdGuardDNS:dns.adguard-dns.com NextDNS:dns.nextdns.io"

echo "🔒 DNS over HTTPS (DoH)"

for resolver in $RESOLVERS_DOH; do
    name=${resolver%%:*}
    host=${resolver#*:}
    dns_query "https" "$name" "$host"
done

echo ""
echo "🔒 DNS over TLS (DoT)"

for resolver in $RESOLVERS_DOT; do
    name=${resolver%%:*}
    host=${resolver#*:}
    dns_query "tls" "$name" "$host"
done
