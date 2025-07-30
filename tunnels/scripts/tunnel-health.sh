#!/bin/bash

set -euo pipefail

# Tunnel health check script
# Usage: ./tunnel-health.sh [domain]

check_domain_health() {
    local domain="${1:-r2d2.reinventingai.com}"
    
    echo "Checking tunnel health for $domain"
    echo "=================================="
    
    # DNS resolution check
    echo "DNS Resolution:"
    if dig +short "$domain" | grep -q "."; then
        echo "✓ DNS resolves correctly"
        dig +short "$domain"
    else
        echo "✗ DNS resolution failed"
        return 1
    fi
    
    echo ""
    
    # HTTP connectivity check
    echo "HTTP Connectivity:"
    if curl -s -o /dev/null -w "%{http_code}" "https://$domain" | grep -q "200\|302"; then
        local response_time=$(curl -s -o /dev/null -w "%{time_total}" "https://$domain")
        echo "✓ HTTPS connection successful"
        echo "Response time: ${response_time}s"
    else
        echo "✗ HTTPS connection failed"
        return 1
    fi
    
    echo ""
    
    # SSL certificate check
    echo "SSL Certificate:"
    local cert_info=$(echo | openssl s_client -servername "$domain" -connect "$domain:443" 2>/dev/null | openssl x509 -noout -dates 2>/dev/null)
    if [[ -n "$cert_info" ]]; then
        echo "✓ SSL certificate valid"
        echo "$cert_info"
    else
        echo "✗ SSL certificate check failed"
        return 1
    fi
    
    echo ""
    echo "All health checks passed for $domain"
}

main() {
    local domain="${1:-}"
    
    if [[ -z "$domain" ]]; then
        echo "Usage: $0 <domain>"
        echo "Example: $0 r2d2.reinventingai.com"
        exit 1
    fi
    
    check_domain_health "$domain"
}

main "$@"