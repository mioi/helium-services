#!/bin/bash
set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting Helium Services with Cloudflare Tunnel...${NC}"
echo ""

# Load environment variables
. ./.env

# Check if tunnel token is set
if [ -z "${CLOUDFLARE_TUNNEL_TOKEN:-}" ] || [ "$CLOUDFLARE_TUNNEL_TOKEN" = "your-tunnel-token-here" ]; then
    echo -e "${YELLOW}Warning: CLOUDFLARE_TUNNEL_TOKEN not set in .env${NC}"
    echo ""
    echo "Please add your Cloudflare Tunnel token to .env:"
    echo "1. Go to https://one.dash.cloudflare.com/"
    echo "2. Navigate to Networks → Tunnels"
    echo "3. Create or view your tunnel"
    echo "4. Copy the token and add it to .env"
    echo ""
    exit 1
fi

echo -e "${GREEN}✓${NC} Environment variables loaded"
echo -e "${GREEN}✓${NC} Tunnel token found"
echo ""

# Build and start services
echo -e "${BLUE}Building and starting services...${NC}"
docker compose build
docker compose up -d

# Fake SSL requirements so nginx can start
docker compose exec acme.sh touch /certs/fullchain.pem

echo ""
echo -e "${GREEN}✓${NC} Services started"
echo ""

# Wait for services to be ready
echo "Waiting for services to initialize..."
sleep 5

# Check tunnel status
echo ""
echo -e "${BLUE}Checking Cloudflare Tunnel status...${NC}"
docker compose logs cloudflared | tail -10

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Your services are now accessible at:"
echo "  🌐 https://${SERVICES_HOSTNAME}/ext"
echo "  🌐 https://${SERVICES_HOSTNAME}/ubo"
echo ""
echo "SSL is automatically handled by Cloudflare."
echo "No certificate setup needed!"
echo ""
echo "Useful commands:"
echo "  View logs:        docker compose logs -f"
echo "  Stop services:    docker compose down"
echo "  Restart:          docker compose restart"
echo ""
