import express from 'express';
import { exec } from 'child_process';
import { promisify } from 'util';

const router = express.Router();
const execAsync = promisify(exec);

// Helper to execute commands on the server
async function executeCommand(command, options = {}) {
  const isLocalhost = process.env.SERVER_HOST === 'localhost' || 
                     process.env.SERVER_HOST === '127.0.0.1' ||
                     process.env.SERVER_HOST === '192.168.4.100';

  let fullCommand;
  if (isLocalhost) {
    fullCommand = `DISPLAY=:10 ${command}`;
  } else {
    // For remote, use SSH
    const host = process.env.SERVER_HOST || '192.168.4.100';
    const username = process.env.SSH_USER || 'andrew';
    fullCommand = `ssh -o StrictHostKeyChecking=no ${username}@${host} "DISPLAY=:10 ${command}"`;
  }

  console.log(`Executing: ${fullCommand}`);
  try {
    const { stdout, stderr } = await execAsync(fullCommand, { timeout: 30000 });
    if (stderr) {
      console.error(`Stderr: ${stderr}`);
    }
    return { success: true, output: stdout, error: stderr };
  } catch (error) {
    console.error(`Command failed: ${error.message}`);
    return { success: false, output: '', error: error.message };
  }
}

// GET /api/vnc/status - Check x11vnc status
router.get('/status', async (req, res, next) => {
  try {
    const result = await executeCommand('ps aux | grep -v grep | grep x11vnc');
    
    if (result.output.trim().length > 0) {
      const processInfo = result.output.split('\n')[0];
      const hasModtweak = processInfo.includes('-modtweak');
      const hasRepeat = processInfo.includes('-repeat');
      const hasXkb = processInfo.includes('-xkb');
      
      res.json({
        running: true,
        processInfo: processInfo,
        flags: {
          modtweak: hasModtweak,
          repeat: hasRepeat,
          xkb: hasXkb
        },
        allFlagsGood: hasModtweak && hasRepeat && hasXkb
      });
    } else {
      res.json({ running: false });
    }
  } catch (error) {
    console.error('Error checking x11vnc status:', error);
    res.status(500).json({ error: 'Failed to check x11vnc status', details: error.message });
  }
});

// POST /api/vnc/restart - Restart x11vnc with enhanced flags
router.post('/restart', async (req, res, next) => {
  try {
    // Kill existing
    await executeCommand('pkill x11vnc');
    
    // Wait a moment
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    // Start with enhanced flags
    const startCommand = `x11vnc -display :10 -auth guess -forever -loop -noxdamage -repeat -modtweak -xkb -noscr -nowf -wait 10 -defer 10 -rfbauth ~/.vnc/passwd -rfbport 5900 -shared -bg -o /tmp/x11vnc.log -verbose`;
    
    const result = await executeCommand(startCommand);
    
    // Wait and verify
    await new Promise(resolve => setTimeout(resolve, 2000));
    const statusResult = await executeCommand('ps aux | grep -v grep | grep x11vnc');
    
    if (statusResult.output.trim().length > 0) {
      res.json({ 
        success: true, 
        message: 'x11vnc restarted with enhanced keyboard support',
        processInfo: statusResult.output.split('\n')[0]
      });
    } else {
      res.status(500).json({ 
        success: false, 
        error: 'x11vnc failed to start',
        output: result.output,
        errorDetails: result.error
      });
    }
  } catch (error) {
    console.error('Error restarting x11vnc:', error);
    res.status(500).json({ error: 'Failed to restart x11vnc', details: error.message });
  }
});

// GET /api/vnc/keyboard-settings - Check X server keyboard settings
router.get('/keyboard-settings', async (req, res, next) => {
  try {
    const xsetResult = await executeCommand('xset q');
    
    const keyboardRepeat = xsetResult.output.includes('auto-repeat: on');
    const repeatRateMatch = xsetResult.output.match(/repeat rate:\s*(\d+)\s*(\d+)/);
    
    res.json({
      keyboardRepeat: keyboardRepeat,
      repeatRate: repeatRateMatch ? {
        delay: parseInt(repeatRateMatch[1]),
        rate: parseInt(repeatRateMatch[2])
      } : null,
      rawOutput: xsetResult.output
    });
  } catch (error) {
    console.error('Error checking keyboard settings:', error);
    res.status(500).json({ error: 'Failed to check keyboard settings', details: error.message });
  }
});

// POST /api/vnc/enable-keyboard-repeat - Enable keyboard repeat on X server
router.post('/enable-keyboard-repeat', async (req, res, next) => {
  try {
    const result1 = await executeCommand('xset r on');
    const result2 = await executeCommand('xset r rate 200 30');
    
    res.json({
      success: result1.success && result2.success,
      message: 'Keyboard repeat enabled',
      output: result1.output + result2.output
    });
  } catch (error) {
    console.error('Error enabling keyboard repeat:', error);
    res.status(500).json({ error: 'Failed to enable keyboard repeat', details: error.message });
  }
});

// GET /api/vnc/logs - Get recent x11vnc logs
router.get('/logs', async (req, res, next) => {
  try {
    const lines = parseInt(req.query.lines) || 50;
    const result = await executeCommand(`tail -n ${lines} /tmp/x11vnc.log 2>/dev/null || echo "Log file not found"`);
    
    res.json({
      logs: result.output,
      lines: lines
    });
  } catch (error) {
    console.error('Error getting logs:', error);
    res.status(500).json({ error: 'Failed to get logs', details: error.message });
  }
});

export default router;


