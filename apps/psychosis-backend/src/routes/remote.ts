import express from 'express';
import { exec } from 'child_process';
import { promisify } from 'util';

const router = express.Router();
const execAsync = promisify(exec);

/**
 * POST /api/remote/execute
 * Execute a command on a remote server via SSH
 * Body: { host: string, username?: string, password?: string, command: string }
 */
router.post('/execute', async (req, res, next) => {
  try {
    const { host, username, password, command } = req.body;
    
    if (!host || !command) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Host and command are required'
      });
    }
    
    // Check if we're executing on localhost (backend is on the same machine)
    const isLocalhost = host === 'localhost' || host === '127.0.0.1' || host === '::1' || 
                       host === process.env.SERVER_HOST || host === '192.168.4.100';
    
    let execCommand: string;
    if (isLocalhost) {
      // Execute directly on local machine
      execCommand = command;
    } else {
      // Build SSH command for remote execution
      // Note: For production, use SSH keys instead of passwords
      if (username) {
        if (password) {
          // Use sshpass for password authentication (requires sshpass installed)
          execCommand = `sshpass -p '${password}' ssh -o StrictHostKeyChecking=no ${username}@${host} '${command}'`;
        } else {
          // Use SSH key authentication
          execCommand = `ssh -o StrictHostKeyChecking=no ${username}@${host} '${command}'`;
        }
      } else {
        // Try without username (uses current user)
        execCommand = `ssh -o StrictHostKeyChecking=no ${host} '${command}'`;
      }
    }
    
    try {
      const { stdout, stderr } = await execAsync(execCommand, {
        timeout: 10000, // 10 second timeout
        env: isLocalhost ? { ...process.env, DISPLAY: ':0' } : process.env
      });
      
      res.json({
        success: true,
        output: stdout,
        error: stderr || null
      });
    } catch (error: any) {
      res.status(500).json({
        error: 'Command Execution Failed',
        message: error.message,
        output: error.stdout || null,
        errorOutput: error.stderr || null
      });
    }
  } catch (error) {
    next(error);
  }
});

/**
 * POST /api/remote/cursor/check
 * Check if Cursor is running on remote server
 * Body: { host: string, username?: string, password?: string }
 */
router.post('/cursor/check', async (req, res, next) => {
  try {
    const { host, username, password } = req.body;
    
    if (!host) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Host is required'
      });
    }
    
    // Check if Cursor process is running
    const command = "pgrep -f 'cursor|Cursor' || echo 'not_running'";
    
    const isLocalhost = host === 'localhost' || host === '127.0.0.1' || host === '::1' || 
                       host === process.env.SERVER_HOST || host === '192.168.4.100';
    
    let execCommand: string;
    if (isLocalhost) {
      execCommand = command;
    } else {
      if (username) {
        if (password) {
          execCommand = `sshpass -p '${password}' ssh -o StrictHostKeyChecking=no ${username}@${host} '${command}'`;
        } else {
          execCommand = `ssh -o StrictHostKeyChecking=no ${username}@${host} '${command}'`;
        }
      } else {
        execCommand = `ssh -o StrictHostKeyChecking=no ${host} '${command}'`;
      }
    }
    
    try {
      const { stdout } = await execAsync(execCommand, { 
        timeout: 5000,
        env: isLocalhost ? { ...process.env, DISPLAY: ':0' } : process.env
      });
      const isRunning = !stdout.includes('not_running') && stdout.trim().length > 0;
      
      res.json({
        isRunning,
        pid: isRunning ? stdout.trim().split('\n')[0] : null
      });
    } catch (error) {
      // If command fails, assume not running
      res.json({
        isRunning: false,
        pid: null
      });
    }
  } catch (error) {
    next(error);
  }
});

/**
 * POST /api/remote/cursor/start
 * Start Cursor on remote server
 * Body: { host: string, username?: string, password?: string }
 */
router.post('/cursor/start', async (req, res, next) => {
  try {
    const { host, username, password } = req.body;
    
    if (!host) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Host is required'
      });
    }
    
    const isLocalhost = host === 'localhost' || host === '127.0.0.1' || host === '::1' || 
                       host === process.env.SERVER_HOST || host === '192.168.4.100';
    
    // Start Cursor - try multiple methods
    const commands = [
      'DISPLAY=:0 cursor > /dev/null 2>&1 &', // With display, background
      'nohup DISPLAY=:0 cursor > /dev/null 2>&1 &', // Background with nohup
      'cursor > /dev/null 2>&1 &', // Direct background
      'DISPLAY=:0 nohup cursor &' // Alternative
    ];
    
    let lastError: Error | null = null;
    for (const command of commands) {
      try {
        let execCommand: string;
        if (isLocalhost) {
          execCommand = command;
        } else {
          let sshCommand: string;
          if (username) {
            if (password) {
              sshCommand = `sshpass -p '${password}' ssh -o StrictHostKeyChecking=no ${username}@${host}`;
            } else {
              sshCommand = `ssh -o StrictHostKeyChecking=no ${username}@${host}`;
            }
          } else {
            sshCommand = `ssh -o StrictHostKeyChecking=no ${host}`;
          }
          execCommand = `${sshCommand} '${command}'`;
        }
        
        await execAsync(execCommand, { 
          timeout: 5000,
          env: isLocalhost ? { ...process.env, DISPLAY: ':0' } : process.env
        });
        res.json({ success: true, method: command });
        return;
      } catch (error: any) {
        lastError = error;
        continue;
      }
    }
    
    res.status(500).json({
      error: 'Failed to start Cursor',
      message: lastError?.message || 'All start methods failed'
    });
  } catch (error) {
    next(error);
  }
});

/**
 * POST /api/remote/cursor/focus
 * Bring Cursor window to front
 * Body: { host: string, username?: string, password?: string }
 */
router.post('/cursor/focus', async (req, res, next) => {
  try {
    const { host, username, password } = req.body;
    
    if (!host) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Host is required'
      });
    }
    
    const isLocalhost = host === 'localhost' || host === '127.0.0.1' || host === '::1' || 
                       host === process.env.SERVER_HOST || host === '192.168.4.100';
    
    // Use xdotool or wmctrl to focus Cursor window
    const commands = [
      "xdotool search --name 'Cursor' windowactivate",
      "wmctrl -a 'Cursor'",
      "xdotool search --class 'cursor' windowactivate",
      "xdotool search --name 'cursor' windowactivate"
    ];
    
    let lastError: Error | null = null;
    for (const command of commands) {
      try {
        let execCommand: string;
        if (isLocalhost) {
          execCommand = `DISPLAY=:0 ${command}`;
        } else {
          let sshCommand: string;
          if (username) {
            if (password) {
              sshCommand = `sshpass -p '${password}' ssh -o StrictHostKeyChecking=no ${username}@${host}`;
            } else {
              sshCommand = `ssh -o StrictHostKeyChecking=no ${username}@${host}`;
            }
          } else {
            sshCommand = `ssh -o StrictHostKeyChecking=no ${host}`;
          }
          execCommand = `${sshCommand} 'DISPLAY=:0 ${command}'`;
        }
        
        await execAsync(execCommand, { 
          timeout: 3000,
          env: isLocalhost ? { ...process.env, DISPLAY: ':0' } : process.env
        });
        res.json({ success: true, method: command });
        return;
      } catch (error: any) {
        lastError = error;
        continue;
      }
    }
    
    res.status(500).json({
      error: 'Failed to focus Cursor',
      message: lastError?.message || 'All focus methods failed'
    });
  } catch (error) {
    next(error);
  }
});

export default router;

