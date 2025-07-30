# R2D2 Tunnel Configuration

How the r2d2.reinventingai.com domain connects to our n8n service.

## What This Does

The r2d2.reinventingai.com domain uses Cloudflare tunnels to securely connect to our n8n service without exposing any ports directly to the internet.

Think of it like this:
```
Your browser → Cloudflare → Secure tunnel → n8n service (port 5678)
```

## Current Setup

- **Website URL:** r2d2.reinventingai.com
- **What it connects to:** n8n service running on port 5678
- **Security:** HTTPS with SSL certificates managed by Cloudflare

## How It Works

1. You type r2d2.reinventingai.com in your browser
2. Cloudflare receives your request
3. Cloudflare securely forwards it through a tunnel to our server
4. Our n8n service receives the request and responds
5. The response goes back through the tunnel to your browser

## Testing the Connection

You can test if the tunnel is working properly:

```bash
./tunnels/scripts/tunnel-health.sh r2d2.reinventingai.com
```

This script checks:
- DNS is working (domain name resolves to an IP address)
- HTTPS connection works
- SSL certificate is valid

## Troubleshooting

**Can't access r2d2.reinventingai.com:**
1. Check if the n8n service is running: `docker ps`
2. Test the tunnel: `./tunnels/scripts/tunnel-health.sh r2d2.reinventingai.com`
3. Look at n8n logs: `docker logs n8n-gabe`

**Website loads slowly:**
1. Check if the n8n service is responding quickly
2. Look at Cloudflare analytics for performance data

## Maintenance Notes

- Cloudflare automatically updates the tunnel software
- SSL certificates renew automatically through Cloudflare
- DNS changes need to be coordinated with whoever manages the domain
- Always test changes in a development environment first