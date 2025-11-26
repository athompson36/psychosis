# Server Services and Ports

**Server:** 192.168.4.100  
**Date Verified:** 2024-11-25

## Docker Container Services

### Web Services

| Service | Container Name | Port(s) | Status | Description |
|---------|---------------|---------|--------|-------------|
| Hub Frontend | `rydell-maint-hub` | **80** (HTTP) | ⚠️ Unhealthy | Main hub frontend application |
| Hub Backend | `rydell-backend` | **4000** | ✅ Healthy | Backend API service (Node.js) |
| noVNC | `novnc` | **6080** | ✅ Running | VNC web client (for remote desktop) |
| Portainer | `portainer` | **9000** | ✅ Running | Docker container management UI |
| Astryx API | `astryx_api_prod` | **8080** (bound to 192.168.4.100) | ✅ Healthy | Astryx production API |
| Minecraft Dashboard | `minecraft-dashboard` | **25564** | ✅ Running | Minecraft server dashboard |

### Database Services

| Service | Container Name | Port(s) | Status | Description |
|---------|---------------|---------|--------|-------------|
| PostgreSQL | `astryx_db_prod` | **5432** | ✅ Healthy | Astryx production database |

### Minecraft Servers

| Service | Container Name | Port(s) | Status | Description |
|---------|---------------|---------|--------|-------------|
| Main Minecraft | `d-minecraft` | **25565** | ✅ Running | Primary Minecraft server |
| Modded Minecraft | `m-minecraft` | **25566** | ✅ Running | Modded Minecraft server |
| Cobblemon | `mc-cobblemon` | - | ⚠️ Restarting | Cobblemon Minecraft server (currently restarting) |

### Infrastructure Services

| Service | Container Name | Port(s) | Status | Description |
|---------|---------------|---------|--------|-------------|
| Portainer Agent | `portainer_agent` | **9001** (bound to 192.168.4.100) | ✅ Running | Portainer agent for container management |
| Portainer Agent (Minecraft) | `portainer_agent_minecraft` | **9002** (bound to 192.168.4.100) | ✅ Running | Portainer agent for Minecraft stack |

## System Services

### Network Services

| Service | Port(s) | Description |
|---------|---------|-------------|
| SSH | **22** | Secure shell access |
| DNS | **53** | Domain name resolution (127.0.0.53) |
| CUPS | **631** | Print server (localhost only) |
| RDP | **3389** | Remote Desktop Protocol |

### Application Processes

| Process | Port(s) | Description |
|---------|---------|-------------|
| Node.js (MCP Server) | - | MCP server process running in `astryx_api_prod` |
| Python (app.py) | - | Python application process |
| Java (Minecraft) | **25565, 25566** | Multiple Minecraft server instances |
| Nginx | **80** | Web server (likely reverse proxy) |
| Supervisord | - | Process manager for noVNC |
| Websockify | **8080** | WebSocket proxy for VNC (internal) |

## Service Health Summary

### ✅ Healthy Services
- Hub Backend (port 4000)
- noVNC (port 6080)
- Portainer (port 9000)
- Astryx API (port 8080)
- Astryx Database (port 5432)
- All Portainer agents
- Main Minecraft servers (ports 25565, 25566)

### ⚠️ Issues Detected
- **rydell-maint-hub** (port 80): Container status shows "unhealthy"
- **mc-cobblemon**: Container is in restart loop

## Key Ports for Hub Application

For the Psychosis Hub application, the following services are relevant:

1. **Hub Backend API**: Port **4000** ✅
   - Backend service for the hub application
   - Node.js/Express server
   - Database: SQLite (file:/app/prisma/dev.db)

2. **Hub Frontend**: Port **80** ⚠️
   - Frontend web application
   - Currently showing as unhealthy in Docker

3. **noVNC**: Port **6080** ✅
   - Remote desktop/VNC access
   - Used for connecting to remote servers
   - **Fixed 2024-11-26**: Corrected Docker port mapping from `6080:6080` to `6080:8080` (websockify listens on 8080 inside container)

## Notes

- The hub backend is running and accessible on port 4000
- The frontend container shows as unhealthy - may need investigation
- All Minecraft servers are operational except for the Cobblemon server
- Portainer is available for container management on port 9000
- SSH access is available on the standard port 22

## Recent Fixes

**2024-11-26 - noVNC Port Mapping Fix:**
- Issue: noVNC container had incorrect port mapping (`6080:6080` instead of `6080:8080`)
- Symptom: Connection refused errors when trying to connect to `http://192.168.4.100:6080/vnc.html`
- Fix: Recreated container with correct mapping: `docker run -d --name novnc -p 6080:8080 theasp/novnc:latest`
- Status: ✅ Resolved - noVNC is now accessible on port 6080

