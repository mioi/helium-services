# helium services

monorepo for all services hosted on *services.helium.imput.net*.

for setup, refer to the [setup.sh](setup.sh) script and the [example .env file](.env.example).

## Cloudflare Tunnel Setup

These services can run locally on your machine (or on a remote server) and be exposed securely via Cloudflare Tunnel.

### Prerequisites

1. A Cloudflare account
2. A domain managed by Cloudflare (or added to Cloudflare)
3. Docker and Docker Compose installed

### Setup Steps

1. **Copy environment template:**
   ```bash
   cp .env.example .env
   ```

2. **Create a Cloudflare Tunnel:**
   - Go to https://one.dash.cloudflare.com/
   - Navigate to **Networks** → **Connectors**
   - Click **"Create a tunnel"**
   - Select **"Cloudflared"** connector
   - Name your tunnel (e.g., `helium-services`) and click **"Save tunnel"**
   - Copy the tunnel token shown (the long random string in the example commands)

3. **Configure the tunnel hostname:**
   Add a public hostname:
   - **Subdomain:** `helium-services` (or your choice)
   - **Domain:** Select your domain
   - **Type:** `HTTP`
   - **URL:** `nginx:80`
   - Click **"Save hostname"**

4. **Generate a secure `HMAC_SECRET`:**
   ```bash
   openssl rand -base64 32
   ```

5. **Update `.env` file:**
   ```bash
   SERVICES_HOSTNAME=helium-services.yourdomain.com
   HMAC_SECRET=<output-from-step-4>
   PROXY_BASE_URL=https://helium-services.yourdomain.com/ext
   UBO_PROXY_BASE_URL=https://helium-services.yourdomain.com/ubo
   CLOUDFLARE_TUNNEL_TOKEN=<your-tunnel-token-from-step-2>
   ```

6. **Run the tunnel setup script:**
   ```bash
   ./setup-tunnel.sh
   ```

### How It Works

- Cloudflare Tunnel creates a secure outbound connection from your machine to Cloudflare's edge
- SSL is handled by Cloudflare (no need for Let's Encrypt)
- No ports need to be opened on your router/firewall
- Your public IP is never exposed

### Managing the Tunnel

```bash
# Start services (including tunnel)
docker compose up -d

# Stop services
docker compose down --remove-orphans

# View tunnel status
docker compose logs -f cloudflared

# Stop just the tunnel (keeps services running locally)
docker compose stop cloudflared

# Restart tunnel
docker compose start cloudflared
```

### Accessing Services

Once running, your services will be available at:
- Extension proxy: `https://helium-services.yourdomain.com/ext`
- UBO proxy: `https://helium-services.yourdomain.com/ubo`
- Bangs: `https://helium-services.yourdomain.com/bangs.json`

In Helium's [Settings > Privacy and security > Helium services](helium://settings/privacy/services), add the URL at the bottom, under "Use your own instance of Helium services", in the form https://helium-services.yourdomain.com
