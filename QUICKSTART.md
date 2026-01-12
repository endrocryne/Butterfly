# Quick Start Guide - Butterfly Web App

This guide provides comprehensive, step-by-step instructions for compiling and deploying the Butterfly web application.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start (Local Development)](#quick-start-local-development)
- [Compilation](#compilation)
- [Deployment Options](#deployment-options)
  - [Option 1: Docker (Recommended)](#option-1-docker-recommended)
  - [Option 2: Docker Compose](#option-2-docker-compose)
  - [Option 3: Manual Web Server Deployment](#option-3-manual-web-server-deployment)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)
- [Advanced Configuration](#advanced-configuration)

---

## Prerequisites

Before you begin, ensure you have the following installed on your system:

### Required Software

1. **Git**
   - Download: https://git-scm.com/downloads
   - Verify installation: `git --version`

2. **Flutter SDK (version 3.38.5)**
   - Download: https://flutter.dev/docs/get-started/install
   - Verify installation: `flutter --version`
   - Note: Butterfly requires Flutter 3.38.5 as specified in `pubspec.yaml`

3. **Dart SDK (>= 3.8.0)**
   - Included with Flutter
   - Verify: `dart --version`

### System Dependencies

#### Linux (Ubuntu/Debian)
```bash
sudo apt-get update
sudo apt-get install -y \
  curl \
  git \
  wget \
  unzip \
  libsecret-1-dev \
  libjsoncpp-dev \
  fonts-droid-fallback
```

#### macOS
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install git
```

#### Windows
- Install Visual Studio Build Tools or Visual Studio Community Edition
- Install all Flutter dependencies
- Install the ATL library via Visual Studio Installer

### Optional (For Docker Deployment)

4. **Docker**
   - Download: https://docs.docker.com/get-docker/
   - Verify: `docker --version`

5. **Docker Compose** (optional)
   - Usually included with Docker Desktop
   - Verify: `docker-compose --version`

---

## Quick Start (Local Development)

Get the app running locally in under 5 minutes:

```bash
# 1. Clone the repository
git clone https://github.com/LinwoodDev/butterfly.git
cd butterfly

# 2. Navigate to the app directory
cd app

# 3. Get Flutter dependencies
flutter pub get

# 4. Run the web app in development mode
flutter run -d chrome
```

The app will open in your default Chrome browser at `http://localhost:PORT` (port assigned automatically).

---

## Compilation

### Build for Production

To compile the web app for production deployment:

```bash
# Navigate to the app directory
cd app

# Install dependencies
flutter pub get

# Build the web application
flutter build web
```

**Build Output:**
- The compiled files will be in: `app/build/web/`
- This directory contains all static assets ready for deployment

### Build Configuration

The default build uses the production configuration. To build with specific configurations:

```bash
# Production build (default)
flutter build web

# Build with specific entrypoint
flutter build web --target lib/main.dart

# Build with release optimization
flutter build web --release

# Build with web renderer options
flutter build web --web-renderer canvaskit  # Better performance, larger size
flutter build web --web-renderer html       # Smaller size, basic features
```

---

## Deployment Options

### Option 1: Docker (Recommended)

Docker provides the easiest and most consistent deployment method.

#### Using Pre-built Image from Docker Hub

```bash
# Pull the latest stable version
docker pull linwooddev/butterfly:stable

# Run the container
docker run -d \
  --name butterfly \
  -p 8080:80 \
  --restart unless-stopped \
  linwooddev/butterfly:stable
```

**Available Tags:**
- `:latest` - Current main branch (development)
- `:stable` - Latest stable release (recommended)
- `:nightly` - Latest nightly release (experimental)
- `:dev` - Current develop branch
- `:vX.X.X` - Specific version releases

**Access the app:** Open your browser to `http://localhost:8080`

#### Building Custom Docker Image

If you want to build from source:

```bash
# From the repository root
docker build -t butterfly-custom .

# Run your custom build
docker run -d \
  --name butterfly \
  -p 8080:80 \
  --restart unless-stopped \
  butterfly-custom
```

### Option 2: Docker Compose

For easier container management, use Docker Compose:

#### Step 1: Review docker-compose.yml

The repository includes a `docker-compose.yml` file:

```yaml
services:
  butterfly:
    build:
      context: .
    container_name: butterfly
    ports:
      - "8080:80"  # Uncomment and configure as needed
    restart: always
```

#### Step 2: Configure Ports

Edit `docker-compose.yml` and uncomment the ports section:

```yaml
ports:
  - "8080:80"  # Maps host port 8080 to container port 80
```

#### Step 3: Deploy

```bash
# From the repository root
docker-compose up -d

# View logs
docker-compose logs -f butterfly

# Stop the service
docker-compose down
```

**Access the app:** Open your browser to `http://localhost:8080`

### Option 3: Manual Web Server Deployment

Deploy to any standard web server (Nginx, Apache, Caddy, etc.).

#### Step 1: Build the Application

```bash
cd app
flutter pub get
flutter build web
```

#### Step 2: Prepare Build Files

The build output is in `app/build/web/`. This directory contains:
- `index.html` - Main entry point
- `flutter.js` - Flutter engine loader
- `manifest.json` - PWA manifest
- `assets/` - App assets and resources
- `canvaskit/` - CanvasKit rendering engine
- `icons/` - PWA icons

#### Step 3: Deploy to Web Server

##### Using Nginx

1. **Install Nginx:**
   ```bash
   # Ubuntu/Debian
   sudo apt-get install nginx
   
   # macOS
   brew install nginx
   ```

2. **Copy files to web root:**
   ```bash
   sudo cp -r app/build/web/* /var/www/html/butterfly/
   ```

3. **Configure Nginx:**
   
   Create `/etc/nginx/sites-available/butterfly`:
   ```nginx
   server {
       listen 80;
       server_name butterfly.yourdomain.com;  # Change to your domain
       
       root /var/www/html/butterfly;
       index index.html;
       
       location / {
           try_files $uri $uri/ /index.html;
       }
       
       # Enable gzip compression
       gzip on;
       gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
       
       # Cache static assets
       location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
           expires 1y;
           add_header Cache-Control "public, immutable";
       }
   }
   ```

4. **Enable site and restart:**
   ```bash
   sudo ln -s /etc/nginx/sites-available/butterfly /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl restart nginx
   ```

##### Using Apache

1. **Install Apache:**
   ```bash
   sudo apt-get install apache2
   ```

2. **Copy files:**
   ```bash
   sudo cp -r app/build/web/* /var/www/html/butterfly/
   ```

3. **Configure Apache:**
   
   Create `/etc/apache2/sites-available/butterfly.conf`:
   ```apache
   <VirtualHost *:80>
       ServerName butterfly.yourdomain.com
       DocumentRoot /var/www/html/butterfly
       
       <Directory /var/www/html/butterfly>
           Options Indexes FollowSymLinks
           AllowOverride All
           Require all granted
           
           # Enable rewrite for SPA
           RewriteEngine On
           RewriteBase /
           RewriteRule ^index\.html$ - [L]
           RewriteCond %{REQUEST_FILENAME} !-f
           RewriteCond %{REQUEST_FILENAME} !-d
           RewriteRule . /index.html [L]
       </Directory>
   </VirtualHost>
   ```

4. **Enable site and restart:**
   ```bash
   sudo a2enmod rewrite
   sudo a2ensite butterfly
   sudo systemctl restart apache2
   ```

##### Using Python HTTP Server (Development Only)

For quick local testing (NOT for production):

```bash
cd app/build/web
python3 -m http.server 8080
```

Access at: `http://localhost:8080`

##### Using Node.js serve (Development Only)

```bash
# Install serve globally
npm install -g serve

# Serve the build directory
cd app/build/web
serve -s . -p 8080
```

Access at: `http://localhost:8080`

---

## Verification

After deployment, verify your installation:

### 1. Basic Functionality Test

1. **Open the application** in your web browser
2. **Create a new note** - Click the "+" button
3. **Draw something** - Test the pen tool
4. **Add text** - Test the text tool
5. **Save the note** - Verify data persistence
6. **Reload the page** - Confirm the note is still there

### 2. PWA Installation Test

1. **Look for install prompt** in your browser (Chrome/Edge)
2. **Install the PWA** to your device
3. **Open the installed app** - Should work offline

### 3. Offline Functionality Test

1. **Disconnect from internet** or enable airplane mode
2. **Open the application** - Should load from cache
3. **Create/edit notes** - Should work offline
4. **Reconnect** - Data should sync if applicable

### 4. Performance Check

- **First Load:** Should complete within 3-5 seconds on good connection
- **Subsequent Loads:** Should load instantly from cache
- **Drawing Performance:** Should be smooth with no lag
- **Browser Console:** Should have no critical errors (F12 → Console)

---

## Troubleshooting

### Build Issues

#### Issue: "Flutter SDK not found"
```bash
# Solution: Ensure Flutter is in your PATH
export PATH="$PATH:/path/to/flutter/bin"
# Or add to ~/.bashrc or ~/.zshrc permanently
```

#### Issue: "Pub get failed"
```bash
# Solution: Clear pub cache and retry
flutter pub cache repair
cd app
flutter pub get
```

#### Issue: "Build fails with dependency errors"
```bash
# Solution: Clean build and reinstall dependencies
cd app
flutter clean
flutter pub get
flutter build web
```

#### Issue: "Wrong Flutter version"
```bash
# Solution: Switch to the required Flutter version
flutter channel beta
flutter upgrade
# Or use fvm for version management
```

### Runtime Issues

#### Issue: "White screen on load"
- **Check browser console** for JavaScript errors (F12)
- **Clear browser cache** and reload
- **Try different browser** to isolate browser-specific issues
- **Check web server configuration** for proper MIME types

#### Issue: "Assets not loading"
- **Verify all files** in `build/web/` are deployed
- **Check file permissions** on web server
- **Verify asset paths** in browser network tab (F12 → Network)

#### Issue: "PWA not installing"
- **Check manifest.json** is accessible at `/manifest.json`
- **Verify HTTPS** - PWAs require HTTPS (except localhost)
- **Check browser compatibility** - Use Chrome/Edge for best support

### Docker Issues

#### Issue: "Port already in use"
```bash
# Solution: Use a different port
docker run -d -p 8081:80 linwooddev/butterfly:stable
```

#### Issue: "Container exits immediately"
```bash
# Solution: Check container logs
docker logs butterfly
```

#### Issue: "Build fails in Docker"
```bash
# Solution: Increase Docker memory allocation
# Docker Desktop: Settings → Resources → Memory (increase to 4GB+)
```

### Web Server Issues

#### Issue: "404 on page refresh"
- **Solution:** Configure URL rewriting to serve `index.html` for all routes
- See web server configuration examples above

#### Issue: "Slow loading"
- **Solution:** Enable gzip compression in web server config
- **Solution:** Configure proper caching headers for static assets

---

## Advanced Configuration

### Custom Base URL

If deploying to a subdirectory (e.g., `yoursite.com/butterfly/`):

```bash
flutter build web --base-href /butterfly/
```

### Environment-Specific Builds

```bash
# Development build with debug info
flutter build web --profile

# Production build with optimizations
flutter build web --release
```

### Custom Splash Screen

To customize the splash screen, edit:
```bash
app/flutter_native_splash-production.yaml
```

Then rebuild:
```bash
cd app
flutter pub run flutter_native_splash:create --path flutter_native_splash-production.yaml
flutter build web
```

### Service Worker Configuration

The PWA service worker is automatically generated. To modify caching behavior, you can customize the service worker after build in `build/web/flutter_service_worker.js`.

### HTTPS Setup

For production, always use HTTPS:

**Using Let's Encrypt with Nginx:**
```bash
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d butterfly.yourdomain.com
```

**Using Let's Encrypt with Apache:**
```bash
sudo apt-get install certbot python3-certbot-apache
sudo certbot --apache -d butterfly.yourdomain.com
```

### Monitoring and Logs

**Docker logs:**
```bash
docker logs -f butterfly
```

**Nginx logs:**
```bash
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

**Apache logs:**
```bash
tail -f /var/log/apache2/access.log
tail -f /var/log/apache2/error.log
```

---

## Additional Resources

- **Main Documentation:** https://butterfly.linwood.dev
- **GitHub Repository:** https://github.com/LinwoodDev/Butterfly
- **Contributing Guide:** [CONTRIBUTING.md](CONTRIBUTING.md)
- **Self-hosting Guide:** [docs/src/content/docs/downloads/selfhosting.md](docs/src/content/docs/downloads/selfhosting.md)
- **Community Support:** 
  - Matrix: https://linwood.dev/matrix
  - Discord: https://discord.linwood.dev

---

## Quick Reference

### Essential Commands

```bash
# Development
flutter run -d chrome

# Build for production
flutter build web

# Docker deployment
docker pull linwooddev/butterfly:stable
docker run -d -p 8080:80 linwooddev/butterfly:stable

# Docker Compose
docker-compose up -d

# View Docker logs
docker logs -f butterfly
```

### File Locations

- **Source code:** `app/lib/`
- **Web build output:** `app/build/web/`
- **Configuration:** `app/pubspec.yaml`
- **Dockerfile:** `./Dockerfile`
- **Docker Compose:** `./docker-compose.yml`

---

**Last Updated:** January 2026  
**Butterfly Version:** 2.5.0-beta.0

For the latest updates and changes, see [CHANGELOG.md](CHANGELOG.md).
