# DNS Resolver Checker

A lightweight shell script to test DNS over HTTPS (DoH) and DNS over TLS (DoT) resolvers.

## Usage
## Quick run:
```bash
wget -O- https://raw.githubusercontent.com/itdoginfo/checkdns/refs/heads/main/checkdns.sh | sh
```

### Test custom domain:
```bash
wget -O- https://raw.githubusercontent.com/itdoginfo/checkdns/refs/heads/main/checkdns.sh | sh -s example.com
```

### Download and run locally:
```bash
wget https://raw.githubusercontent.com/itdoginfo/checkdns/refs/heads/main/checkdns.sh
chmod +x checkdns.sh
./checkdns.sh
```

## Features

- Tests popular DNS resolvers (Cloudflare, Google, Quad9, AdGuard, NextDNS)
- Supports both DoH and DoT protocols
- Clean output with status indicators (✅/❌)
- POSIX-compliant (works with sh, bash, ash)
- Custom domain testing support

## Requirements

- `dig` utility (version 9.18+)

### Installation commands for dig:
- **Debian/Ubuntu**: `sudo apt install dnsutils`
- **OpenWrt**: `opkg install bind-dig`

## Output Example

```
🔒 DNS over HTTPS (DoH)
  ✅ Cloudflare
  ✅ Google
  ✅ Quad9
  ✅ AdGuardDNS
  ✅ NextDNS

🔒 DNS over TLS (DoT)
  ✅ Cloudflare
  ✅ Google
  ✅ Quad9
  ✅ AdGuardDNS
  ✅ NextDNS
```