# Quick Fix for VNC Server Setup

## Current Status
- VNC server starts but exits immediately because xstartup script fails
- noVNC container can't bind to port 8080

## Solution: Use x11vnc to Share Existing Desktop

Since you have display :10 running (xrdp session), we can use x11vnc to share that desktop instead of creating a new VNC server.

### Step 1: Install x11vnc
```bash
sudo apt-get install -y x11vnc
```

### Step 2: Set VNC Password
```bash
x11vnc -storepasswd ~/.vnc/passwd
# Enter your desired VNC password when prompted
```

### Step 3: Start x11vnc Sharing Display :10
```bash
# Kill any existing x11vnc
pkill x11vnc

# Start x11vnc sharing display :10 (your xrdp session)
x11vnc -display :10 -auth guess -forever -loop -noxdamage -repeat -rfbauth ~/.vnc/passwd -rfbport 5900 -shared -bg -o /tmp/x11vnc.log
```

### Step 4: Verify x11vnc is Running
```bash
# Check if x11vnc is running
ps aux | grep x11vnc | grep -v grep

# Check if port 5900 is listening
netstat -tlnp | grep 5900
# or
ss -tlnp | grep 5900
```

### Step 5: Clean Up and Restart noVNC Container
```bash
# Stop and remove old containers
docker stop novnc 2>/dev/null
docker rm novnc 2>/dev/null

# Find and kill any process using port 8080
sudo lsof -i :8080
# Kill the process if found, or use:
sudo fuser -k 8080/tcp

# Start noVNC container connecting to x11vnc
docker run -d --name novnc -p 6080:8080 \
  --network host \
  theasp/novnc:latest \
  websockify --web /usr/share/novnc 8080 localhost:5900

# Check logs
docker logs novnc
```

### Step 6: Test Connection
```bash
# From your Mac, test the connection
curl http://192.168.4.100:6080/vnc.html
```

## Alternative: Fix TigerVNC xstartup Script

If you prefer to use TigerVNC instead of x11vnc:

### Step 1: Install Required Packages
```bash
sudo apt-get install -y xfce4 xfce4-goodies
```

### Step 2: Create Proper xstartup Script
```bash
cat > ~/.vnc/xstartup << 'EOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XKL_XMODMAP_DISABLE=1
export XDG_CURRENT_DESKTOP="XFCE"
export XDG_MENU_PREFIX="xfce-"
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
xsetroot -solid grey
/usr/bin/startxfce4 &
EOF

chmod +x ~/.vnc/xstartup
```

### Step 3: Start VNC Server
```bash
vncserver -kill :1
vncserver :1 -geometry 1920x1080 -depth 24 -localhost no
```

### Step 4: Configure noVNC for Port 5901
```bash
docker stop novnc
docker rm novnc
docker run -d --name novnc -p 6080:8080 \
  --network host \
  theasp/novnc:latest \
  websockify --web /usr/share/novnc 8080 localhost:5901
```

## Verify Everything Works

1. **Check VNC server:**
   ```bash
   ps aux | grep -E '(x11vnc|Xtigervnc)' | grep -v grep
   netstat -tlnp | grep 590
   ```

2. **Check noVNC:**
   ```bash
   docker ps | grep novnc
   docker logs novnc
   curl http://localhost:6080/vnc.html
   ```

3. **Connect from iOS app:**
   - Host: `192.168.4.100`
   - Port: `6080`
   - Path: `/vnc.html`
   - Password: (the VNC password you set)

## Troubleshooting

- **Port 8080 in use:** Use `sudo lsof -i :8080` to find the process and kill it
- **VNC server won't start:** Check logs in `~/.vnc/fs-dev:1.log`
- **Can't connect:** Ensure firewall allows ports 6080 and 5900/5901

