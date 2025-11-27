//
//  ServerPresets.swift
//  PsychosisApp
//
//  Created on [Current Date]
//

import Foundation

struct ServerPreset {
    let name: String
    let description: String
    let icon: String
    let server: RemoteServer
    
    static let presets: [ServerPreset] = [
        ServerPreset(
            name: "Ubuntu noVNC",
            description: "Ubuntu server with noVNC web interface",
            icon: "🖥️",
            server: RemoteServer(
                name: "Ubuntu Server",
                host: "ubuntu.local",
                port: 6080,
                type: .ubuntu,
                connectionPath: "/vnc.html"
            )
        ),
        ServerPreset(
            name: "macOS Screen Sharing",
            description: "macOS with Screen Sharing",
            icon: "💻",
            server: RemoteServer(
                name: "Mac Server",
                host: "mac.local",
                port: 5900,
                type: .mac,
                connectionPath: "/vnc.html"
            )
        ),
        ServerPreset(
            name: "Custom VNC",
            description: "Custom VNC server configuration",
            icon: "🖱️",
            server: RemoteServer(
                name: "Custom VNC",
                host: "192.168.1.100",
                port: 5900,
                type: .ubuntu,
                connectionPath: "/vnc.html"
            )
        ),
        ServerPreset(
            name: "Secure HTTPS",
            description: "Secure connection with SSL/HTTPS",
            icon: "🔒",
            server: RemoteServer(
                name: "Secure Server",
                host: "secure.example.com",
                port: 443,
                type: .ubuntu,
                useSSL: true,
                connectionPath: "/vnc.html"
            )
        )
    ]
}

