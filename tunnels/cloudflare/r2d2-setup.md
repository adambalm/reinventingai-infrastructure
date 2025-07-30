# R2D2 Cloudflare Tunnel Setup

Configuration documentation for r2d2.reinventingai.com tunnel.

## Overview

The r2d2.reinventingai.com domain routes through Cloudflare tunnels to provide secure access to internal services without exposing ports directly.

## Current Configuration

**Domain:** r2d2.reinventingai.com  
**Target Service:** n8n (port 5678)  
**Protocol:** HTTPS with SSL termination at Cloudflare

## DNS Configuration

Cloudflare DNS should have a CNAME record pointing r2d2.reinventingai.com to the tunnel endpoint.

## Service Routing

```
r2d2.reinventingai.com → Cloudflare Tunnel → localhost:5678 (n8n)
```

## SSL Configuration

SSL certificates are managed by Cloudflare. The tunnel provides end-to-end encryption from client to Cloudflare edge.

## Health Monitoring

Use the tunnel health check script to verify connectivity:

```bash
./tunnels/scripts/tunnel-health.sh r2d2.reinventingai.com
```

## Troubleshooting

**Connection Issues:**
1. Verify tunnel daemon is running
2. Check DNS propagation
3. Validate SSL certificate status
4. Confirm service is running on target port

**Performance Issues:**
1. Check tunnel latency
2. Monitor service response times
3. Review Cloudflare analytics

## Maintenance

**Tunnel Updates:**
Cloudflare tunnel client updates automatically. Monitor tunnel logs for any connectivity issues after updates.

**DNS Changes:**  
DNS modifications require coordination with domain administrator. Test changes in staging environment first.