# 🚀 Etherpad Deployment Guide

This guide will help you deploy Etherpad to `notes.zaur.app` on your VPS (`captain.zaur.app`).

## 📋 Prerequisites

- VPS with Ubuntu/Debian Linux
- Domain `notes.zaur.app` pointing to your VPS IP
- SSH access to your VPS
- Git repository access

## 🔧 Quick Deployment

### 1. Prepare Your VPS

```bash
# Connect to your VPS
ssh user@captain.zaur.app

# Clone the repository
git clone https://github.com/nomideusz/etherpad.git
cd etherpad

# Copy and configure environment
cp env.example .env
nano .env  # Set secure passwords
```

### 2. Run Deployment Script

```bash
chmod +x deploy.sh
./deploy.sh
```

### 3. Configure SSL

```bash
# After DNS is configured, get SSL certificate
sudo certbot --nginx -d notes.zaur.app
```

## 📁 File Structure

```
etherpad/
├── docker-compose.prod.yml  # Production Docker setup
├── settings.json           # Etherpad configuration
├── nginx/
│   └── nginx.conf          # Nginx reverse proxy config
├── deploy.sh              # Deployment script
└── env.example            # Environment variables template
```

## 🔐 Environment Variables

Create a `.env` file with:

```bash
ETHERPAD_ADMIN_PASSWORD=your_secure_admin_password_here
POSTGRES_PASSWORD=your_secure_db_password_here
DOMAIN=notes.zaur.app
```

## 🌐 Domain Configuration

1. Point `notes.zaur.app` to your VPS IP address
2. Configure DNS records:
   - A record: `notes.zaur.app` → `YOUR_VPS_IP`
   - Optional: CNAME `*.notes.zaur.app` → `notes.zaur.app`

## 🔒 SSL Certificate

The deployment script prepares everything for SSL. Once DNS is configured:

```bash
sudo certbot --nginx -d notes.zaur.app
```

This will:
- Obtain a free Let's Encrypt certificate
- Configure Nginx to use HTTPS
- Set up automatic renewal

## 📊 Monitoring & Management

### View Logs
```bash
cd /opt/etherpad
docker-compose logs -f etherpad
docker-compose logs -f postgres
docker-compose logs -f nginx
```

### Restart Services
```bash
cd /opt/etherpad
docker-compose restart
```

### Update Etherpad
```bash
cd /opt/etherpad
git pull origin master
docker-compose pull
docker-compose up -d
```

### Backup Database
```bash
cd /opt/etherpad
docker-compose exec postgres pg_dump -U etherpad etherpad > backup_$(date +%Y%m%d_%H%M%S).sql
```

## 🛠️ Admin Interface

Access the admin interface at: `https://notes.zaur.app/admin`

Use the password you set in `ETHERPAD_ADMIN_PASSWORD`.

## 🔧 Troubleshooting

### Etherpad Won't Start
```bash
# Check logs
docker-compose logs etherpad

# Check if database is ready
docker-compose logs postgres
```

### Nginx Issues
```bash
# Test configuration
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx
```

### SSL Issues
```bash
# Check certificate status
sudo certbot certificates

# Renew certificates
sudo certbot renew
```

## 🚀 Production Optimizations

1. **Database Tuning**: Adjust PostgreSQL settings for your server resources
2. **Backup Strategy**: Set up automated database backups
3. **Monitoring**: Add monitoring tools like Prometheus/Grafana
4. **Rate Limiting**: Configure rate limiting in Nginx if needed
5. **Security**: Regularly update Docker images and system packages

## 📞 Support

- Etherpad Documentation: https://etherpad.org/doc/
- GitHub Issues: https://github.com/ether/etherpad-lite/issues
- Community Discord: https://discord.com/invite/daEjfhw
