#!/bin/bash

# Etherpad Deployment Script for notes.zaur.app
# Run this on your VPS (captain.zaur.app)

set -e

echo "🚀 Starting Etherpad deployment to notes.zaur.app..."

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo "❌ This script should not be run as root. Please run as a regular user with sudo access."
   exit 1
fi

# Update system
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install required packages
echo "📦 Installing required packages..."
sudo apt install -y curl wget git docker.io docker-compose nginx certbot python3-certbot-nginx ufw

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group
sudo usermod -aG docker $USER

# Create deployment directory
echo "📁 Creating deployment directory..."
sudo mkdir -p /opt/etherpad
sudo chown $USER:$USER /opt/etherpad

# Copy files to VPS (you'll need to upload these files first)
# This assumes you've already copied the project files to the VPS
cd /opt/etherpad

# Copy configuration files
cp docker-compose.prod.yml docker-compose.yml
cp settings.json settings.json
cp nginx/nginx.conf /etc/nginx/sites-available/notes.zaur.app

# Create environment file (you'll need to set these values)
if [ ! -f .env ]; then
    echo "⚠️  Please create .env file with your passwords:"
    echo "   ETHERPAD_ADMIN_PASSWORD=your_secure_admin_password"
    echo "   POSTGRES_PASSWORD=your_secure_db_password"
    cp env.example .env
    echo "❌ Please edit .env file with secure passwords before continuing."
    exit 1
fi

# Create SSL directory
sudo mkdir -p /etc/nginx/ssl

# Enable Nginx site
sudo ln -sf /etc/nginx/sites-available/notes.zaur.app /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Configure firewall
echo "🔥 Configuring firewall..."
sudo ufw allow ssh
sudo ufw allow 'Nginx Full'
sudo ufw --force enable

# Start services
echo "🐳 Starting Docker containers..."
docker-compose up -d

# Wait for services to start
echo "⏳ Waiting for services to start..."
sleep 30

# Test services
echo "🧪 Testing services..."
if curl -f http://localhost:9001 > /dev/null 2>&1; then
    echo "✅ Etherpad is running locally"
else
    echo "❌ Etherpad failed to start"
    exit 1
fi

# Get SSL certificate (you'll need to configure DNS first)
echo "🔒 Setting up SSL certificate..."
echo "⚠️  Make sure notes.zaur.app DNS points to this server before running:"
echo "   sudo certbot --nginx -d notes.zaur.app"
echo ""
echo "After SSL is configured, your Etherpad will be available at:"
echo "   https://notes.zaur.app"
echo ""
echo "Admin interface: https://notes.zaur.app/admin"
echo ""
echo "🎉 Deployment completed successfully!"
