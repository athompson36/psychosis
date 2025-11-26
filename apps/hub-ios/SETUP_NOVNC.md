# Setting Up noVNC on Ubuntu Server

## Quick Setup Guide

Your iOS app is trying to connect to `fs-dev.local:6080` but getting "Connection refused". This means noVNC (the web-based VNC client) isn't running on your Ubuntu server.

## Option 1: Install noVNC (Recommended)

### Using Docker (Easiest)

```bash
# On your Ubuntu server (fs-dev)
docker run -d \
  --name novnc \
  -p 6080:6080 \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  theasp/novnc:latest
```

### Using System Package

```bash
# Install noVNC and websockify
sudo apt update
sudo apt install -y novnc websockify

# Start VNC server (if not already running)
vncserver :1 -geometry 1920x1080 -depth 24

# Start websockify to bridge VNC to web
websockify --web=/usr/share/novnc/ 6080 localhost:5901
```

### Using Python (Manual)

```bash
# Install dependencies
sudo apt install -y python3-numpy python3-websockify

# Clone noVNC
git clone https://github.com/novnc/noVNC.git /opt/novnc
cd /opt/novnc

# Start websockify
./utils/launch.sh --vnc localhost:5901 --listen 6080
```

## Option 2: Use Existing VNC Server

If you already have a VNC server running on port 5900, you can use websockify to create a web interface:

```bash
# Install websockify
sudo apt install -y websockify

# Bridge VNC port 5900 to web port 6080
websockify --web=/usr/share/novnc/ 6080 localhost:5900
```

## Option 3: Use Different Port

If noVNC is running on a different port, update your server configuration in the iOS app:

1. Edit the server in the app
2. Change the port to match your noVNC port
3. Save and try connecting again

## Verify Setup

After setting up, test from your Mac:

```bash
# Test if port is open
nc -zv fs-dev.local 6080

# Or test in browser
open http://fs-dev.local:6080/vnc.html
```

## Common Issues

### Port Already in Use
```bash
# Check what's using port 6080
sudo lsof -i :6080
# Or
sudo netstat -tlnp | grep 6080
```

### Firewall Blocking
```bash
# Allow port 6080
sudo ufw allow 6080/tcp
sudo ufw reload
```

### VNC Server Not Running
```bash
# Start VNC server
vncserver :1

# Check if running
ps aux | grep vnc
```

## Alternative: Use Cursor's Built-in Web Interface

If Cursor has a built-in web interface, you might be able to access it directly:

1. Check Cursor documentation for web access
2. Update the connection path in the app
3. Use the correct port and path

## Testing Connection

Once noVNC is set up:

1. Test in browser first: `http://fs-dev.local:6080/vnc.html`
2. If that works, try connecting from the iOS app
3. Use the "Test Connection" button in the app for diagnostics

