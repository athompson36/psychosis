# Setting Up VNC Server for Remote Desktop Access

## Problem
The noVNC container is currently using its own internal VNC server (container desktop), which shows as `root@04180c555682`. To connect to your actual Ubuntu desktop (`andrew@192.168.4.100`), you need to set up a VNC server on the host that shares your desktop session.

## Solution: Set Up VNC Server on Ubuntu Host

### Option 1: Using TigerVNC (Recommended)

1. **Install TigerVNC:**
   ```bash
   sudo apt-get update
   sudo apt-get install -y tigervnc-standalone-server tigervnc-common
   ```

2. **Set VNC password:**
   ```bash
   vncpasswd
   # Enter your desired VNC password
   ```

3. **Start VNC server for your user session:**
   ```bash
   # Kill any existing VNC server
   vncserver -kill :1
   
   # Start VNC server on display :1
   vncserver :1 -geometry 1920x1080 -depth 24 -localhost no
   ```

4. **Configure noVNC to connect to host VNC:**
   ```bash
   docker stop novnc
   docker rm novnc
   docker run -d --name novnc -p 6080:8080 \
     --network host \
     theasp/novnc:latest \
     websockify --web /usr/share/novnc 8080 localhost:5901
   ```
   (Note: VNC display :1 = port 5901)

### Option 2: Using x11vnc (Share Existing Desktop)

If you want to share your existing desktop session (display :0 or :10):

1. **Install x11vnc:**
   ```bash
   sudo apt-get install -y x11vnc
   ```

2. **Start x11vnc sharing your desktop:**
   ```bash
   # For display :0 (main display)
   x11vnc -display :0 -auth guess -forever -loop -noxdamage -repeat -rfbauth ~/.vnc/passwd -rfbport 5900 -shared -bg
   
   # Or for display :10 (xrdp session)
   x11vnc -display :10 -auth guess -forever -loop -noxdamage -repeat -rfbauth ~/.vnc/passwd -rfbport 5900 -shared -bg
   ```

3. **Set VNC password:**
   ```bash
   x11vnc -storepasswd ~/.vnc/passwd
   ```

4. **Configure noVNC:**
   ```bash
   docker stop novnc
   docker rm novnc
   docker run -d --name novnc -p 6080:8080 \
     --network host \
     theasp/novnc:latest \
     websockify --web /usr/share/novnc 8080 localhost:5900
   ```

### Option 3: Use the noVNC Container's Internal Desktop

If you just need a remote desktop and don't need your specific Ubuntu desktop:

- The current setup works - it provides a containerized desktop environment
- Access it at `http://192.168.4.100:6080/vnc.html`
- This is what's currently running (shows as `root@04180c555682`)

## Verify Setup

After setting up VNC server:

```bash
# Check if VNC server is running
netstat -tlnp | grep 590

# Test from another machine
curl http://192.168.4.100:6080/vnc.html
```

## Update iOS App Credentials

Once VNC is set up, update your server configuration in the iOS app:
- Host: `192.168.4.100`
- Port: `6080`
- Username: (leave empty or use VNC password)
- Password: (your VNC password, if required)
- Path: `/vnc.html`

## Troubleshooting

- **VNC server won't start:** Check if port 5900/5901 is already in use
- **Can't connect:** Ensure firewall allows port 6080 and 5900/5901
- **Wrong desktop:** Make sure VNC server is sharing the correct display


