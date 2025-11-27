//
//  VNCConnection.swift
//  PsychosisApp
//
//  Native VNC client using direct RFB protocol
//

import Foundation
import Network
import CommonCrypto
import UIKit

@MainActor
class VNCConnection: ObservableObject {
    @Published var isConnected: Bool = false
    @Published var isConnecting: Bool = false
    @Published var errorMessage: String?
    @Published var frameBuffer: VNCFrameBuffer?
    @Published var frameBufferImage: UIImage?
    
    private var connection: NWConnection?
    private var host: String = ""
    private var port: Int = 5900
    private var password: String = ""
    
    private var receiveTask: Task<Void, Never>?
    nonisolated(unsafe) private var dataAvailableContinuation: CheckedContinuation<Data, Error>?
    nonisolated(unsafe) private var pendingReadCount: Int = 0
    nonisolated(unsafe) private var currentReadID: UUID?
    nonisolated(unsafe) private var noDataReceiveCount: Int = 0
    
    init() {}
    
    // MARK: - Connection
    
    func connect(host: String, port: Int, password: String) async throws {
        self.host = host
        self.port = port
        self.password = password
        
        isConnecting = true
        errorMessage = nil
        
        defer {
            isConnecting = false
        }
        
        // Create TCP connection
        let endpoint = NWEndpoint.hostPort(
            host: NWEndpoint.Host(host),
            port: NWEndpoint.Port(integerLiteral: UInt16(port))
        )
        
        connection = NWConnection(to: endpoint, using: .tcp)
        
        // Set state handler
        connection?.stateUpdateHandler = { [weak self] state in
            Task { @MainActor in
                switch state {
                case .ready:
                    print("✅ VNC TCP connection ready")
                    // Start continuous receive immediately when connection is ready
                    self?.startContinuousReceive()
                    do {
                        try await self?.performRFBHandshake()
                        print("✅ RFB handshake completed successfully")
                    } catch {
                        print("❌ RFB handshake failed: \(error)")
                        print("❌ Error type: \(type(of: error))")
                        print("❌ Error description: \(error.localizedDescription)")
                        self?.errorMessage = error.localizedDescription
                        self?.isConnected = false
                    }
                case .failed(let error):
                    print("❌ VNC connection failed: \(error)")
                    self?.errorMessage = error.localizedDescription
                    self?.isConnected = false
                case .cancelled:
                    print("⚠️ VNC connection cancelled")
                    self?.isConnected = false
                default:
                    break
                }
            }
        }
        
        let queue = DispatchQueue(label: "vnc.connection", qos: .userInitiated)
        connection?.start(queue: queue)
    }
    
    func disconnect() {
        receiveTask?.cancel()
        connection?.cancel()
        isConnected = false
        frameBuffer = nil
    }
    
    // MARK: - RFB Protocol Handshake
    
    private func performRFBHandshake() async throws {
        // Step 1: Read protocol version
        let versionData = try await readData(count: 12)
        let versionString = String(data: versionData, encoding: .ascii) ?? ""
        print("📡 RFB Version: \(versionString)")
        
        guard versionString.hasPrefix("RFB ") else {
            throw VNCError.invalidProtocol
        }
        
        // Step 2: Send protocol version
        try await writeData(versionData)
        
        // Step 3: Read security types
        let numSecurityTypes = try await readByte()
        guard numSecurityTypes > 0 else {
            throw VNCError.noSecurityTypes
        }
        
        let securityTypes = try await readData(count: Int(numSecurityTypes))
        print("🔐 Security types available: \(securityTypes.map { $0 })")
        
        // Step 4: Select VNC Authentication (type 2)
        let vncAuthType: UInt8 = 2
        guard securityTypes.contains(vncAuthType) else {
            throw VNCError.vncAuthNotSupported
        }
        
        try await writeByte(vncAuthType)
        
        // Step 5: VNC Authentication
        try await performVNCAuthentication()
        
        // Step 6: Send client init (MUST be sent before server sends ServerInit)
        print("📤 Sending client initialization...")
        try await sendClientInit()
        print("✅ Client initialization sent")
        
        // Step 7: Read server init (server will now respond with ServerInit)
        print("📖 Reading server initialization...")
        let serverInit = try await readServerInit()
        print("🖥️ Server: \(serverInit.width)x\(serverInit.height) - \(serverInit.name)")
        
        // Step 8: Create frame buffer
        print("🖼️ Creating frame buffer: \(serverInit.width)x\(serverInit.height)")
        frameBuffer = VNCFrameBuffer(
            width: Int(serverInit.width),
            height: Int(serverInit.height)
        )
        print("✅ Frame buffer created")
        
        // Step 9: Start receiving updates
        isConnected = true
        print("✅ VNC connection established, starting frame buffer updates")
        startReceivingUpdates()
    }
    
    // MARK: - VNC Authentication
    
    private func performVNCAuthentication() async throws {
        // Read challenge
        let challenge = try await readData(count: 16)
        print("🔑 Received VNC challenge")
        
        // Encrypt password with challenge
        let encrypted = encryptVNCPassword(password: password, challenge: challenge)
        
        // Send encrypted response
        try await writeData(encrypted)
        
        // Read security result (4 bytes: 0 = success, non-zero = failure)
        let result = try await readUInt32()
        print("🔐 Authentication result: \(result) (0 = success)")
        guard result == 0 else {
            let errorMsg = result == 1 ? "Authentication failed - invalid password" : "Authentication failed with code: \(result)"
            print("❌ \(errorMsg)")
            throw VNCError.authenticationFailed
        }
        
        print("✅ VNC authentication successful - server should now send ServerInit")
    }
    
    private func encryptVNCPassword(password: String, challenge: Data) -> Data {
        // VNC uses DES encryption with password padded to 8 bytes
        // Steps:
        // 1. Pad/truncate password to 8 bytes
        // 2. Reverse bits in each byte (VNC quirk)
        // 3. Use as DES key to encrypt challenge
        
        guard challenge.count == 16 else {
            print("⚠️ Invalid challenge length: \(challenge.count)")
            return challenge
        }
        
        // Step 1: Pad/truncate password to 8 bytes
        var keyData = password.prefix(8).data(using: .ascii) ?? Data()
        while keyData.count < 8 {
            keyData.append(0)
        }
        
        // Step 2: Reverse bits in each byte (VNC quirk)
        var reversedKey = Data()
        for byte in keyData {
            var reversedByte: UInt8 = 0
            for i in 0..<8 {
                if (byte & (1 << i)) != 0 {
                    reversedByte |= (1 << (7 - i))
                }
            }
            reversedKey.append(reversedByte)
        }
        
        // Step 3: Encrypt challenge using DES
        // VNC encrypts the challenge in two 8-byte blocks
        var encrypted = Data()
        
        // Encrypt first 8 bytes
        let block1 = challenge.prefix(8)
        if let encrypted1 = encryptDES(data: block1, key: reversedKey) {
            encrypted.append(encrypted1)
        } else {
            print("⚠️ DES encryption failed for block 1")
            return challenge
        }
        
        // Encrypt second 8 bytes
        let block2 = challenge.suffix(8)
        if let encrypted2 = encryptDES(data: block2, key: reversedKey) {
            encrypted.append(encrypted2)
        } else {
            print("⚠️ DES encryption failed for block 2")
            return challenge
        }
        
        return encrypted
    }
    
    private func encryptDES(data: Data, key: Data) -> Data? {
        guard data.count == 8, key.count == 8 else {
            return nil
        }
        
        var encryptedBytes = [UInt8](repeating: 0, count: 8)
        var dataBytes = [UInt8](data)
        var keyBytes = [UInt8](key)
        
        // DES encryption using CommonCrypto CCCrypt
        var numBytesEncrypted: size_t = 0
        
        let status = keyBytes.withUnsafeMutableBytes { keyPtr in
            dataBytes.withUnsafeMutableBytes { dataPtr in
                encryptedBytes.withUnsafeMutableBytes { encryptedPtr in
                    CCCrypt(
                        CCOperation(kCCEncrypt),
                        CCAlgorithm(kCCAlgorithmDES),
                        CCOptions(kCCOptionECBMode),
                        keyPtr.baseAddress,
                        keyPtr.count,
                        nil, // No IV for ECB mode
                        dataPtr.baseAddress,
                        dataPtr.count,
                        encryptedPtr.baseAddress,
                        encryptedPtr.count,
                        &numBytesEncrypted
                    )
                }
            }
        }
        
        if status == kCCSuccess && numBytesEncrypted == 8 {
            return Data(encryptedBytes)
        } else {
            print("⚠️ DES encryption failed with status: \(status), bytes: \(numBytesEncrypted)")
            return nil
        }
    }
    
    // MARK: - Server Init
    
    private struct ServerInit {
        let width: UInt16
        let height: UInt16
        let pixelFormat: PixelFormat
        let name: String
    }
    
    private struct PixelFormat {
        let bitsPerPixel: UInt8
        let depth: UInt8
        let bigEndian: Bool
        let trueColor: Bool
        let redMax: UInt16
        let greenMax: UInt16
        let blueMax: UInt16
        let redShift: UInt8
        let greenShift: UInt8
        let blueShift: UInt8
    }
    
    private func readServerInit() async throws -> ServerInit {
        print("  📐 Reading width and height...")
        let width = try await readUInt16()
        let height = try await readUInt16()
        print("  📐 Dimensions: \(width)x\(height)")
        
        // Read pixel format (16 bytes)
        print("  🎨 Reading pixel format...")
        let pixelFormatData = try await readData(count: 16)
        let pixelFormat = PixelFormat(
            bitsPerPixel: pixelFormatData[0],
            depth: pixelFormatData[1],
            bigEndian: pixelFormatData[2] != 0,
            trueColor: pixelFormatData[3] != 0,
            redMax: UInt16(pixelFormatData[4]) << 8 | UInt16(pixelFormatData[5]),
            greenMax: UInt16(pixelFormatData[6]) << 8 | UInt16(pixelFormatData[7]),
            blueMax: UInt16(pixelFormatData[8]) << 8 | UInt16(pixelFormatData[9]),
            redShift: pixelFormatData[10],
            greenShift: pixelFormatData[11],
            blueShift: pixelFormatData[12]
        )
        print("  🎨 Pixel format: \(pixelFormat.bitsPerPixel) bpp, depth: \(pixelFormat.depth)")
        
        // Read name length
        print("  📝 Reading server name...")
        let nameLength = try await readUInt32()
        print("  📝 Name length: \(nameLength)")
        let nameData = try await readData(count: Int(nameLength))
        let name = String(data: nameData, encoding: .utf8) ?? ""
        print("  📝 Server name: \(name)")
        
        return ServerInit(
            width: width,
            height: height,
            pixelFormat: pixelFormat,
            name: name
        )
    }
    
    private func sendClientInit() async throws {
        // Send shared flag (1 = shared, 0 = exclusive)
        try await writeByte(1)
    }
    
    // MARK: - Continuous Receive Handler
    
    private func startContinuousReceive() {
        guard let connection = self.connection else {
            print("⚠️ Cannot start continuous receive - no connection")
            return
        }
        
        print("🔄 Starting continuous receive handler...")
        
        // Set up a continuous receive handler that buffers incoming data
        nonisolated func receiveLoop() {
            connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, context, isComplete, error in
                guard let self = self else {
                    print("⚠️ Continuous receive: self is nil, stopping")
                    return
                }
                
                if let error = error {
                    print("❌ Continuous receive error: \(error.localizedDescription)")
                    Task { @MainActor in
                        if let continuation = self.dataAvailableContinuation {
                            self.dataAvailableContinuation = nil
                            self.pendingReadCount = 0
                            continuation.resume(throwing: error)
                        }
                    }
                    return
                }
                
                if let data = data, !data.isEmpty {
                    print("📦 Continuous receive got \(data.count) bytes (total buffer: \(self.receiveBuffer.count + data.count))")
                    // Add to buffer on MainActor
                    Task { @MainActor in
                        self.receiveBuffer.append(data)
                        print("📦 Buffer now has \(self.receiveBuffer.count) bytes")
                        
                        // Resume any pending read if we have enough data
                        if let continuation = self.dataAvailableContinuation,
                           self.receiveBuffer.count >= self.pendingReadCount {
                            let needed = self.pendingReadCount
                            let result = self.receiveBuffer.prefix(needed)
                            self.receiveBuffer.removeFirst(needed)
                            self.dataAvailableContinuation = nil
                            self.pendingReadCount = 0
                            print("📦 Resuming pending read with \(needed) bytes from buffer (remaining: \(self.receiveBuffer.count))")
                            continuation.resume(returning: Data(result))
                        }
                    }
                } else {
                    // No data received - this is normal when waiting, but log occasionally
                    Task { @MainActor in
                        self.noDataReceiveCount += 1
                        if self.noDataReceiveCount <= 5 || self.noDataReceiveCount % 50 == 0 {
                            print("📡 Continuous receive: callback fired but no data (count: \(self.noDataReceiveCount), isComplete: \(isComplete))")
                        }
                    }
                }
                
                if isComplete {
                    print("⚠️ Continuous receive: connection completed")
                    Task { @MainActor in
                        if let continuation = self.dataAvailableContinuation {
                            self.dataAvailableContinuation = nil
                            self.pendingReadCount = 0
                            continuation.resume(throwing: VNCError.incompleteData)
                        }
                    }
                    return
                }
                
                // Continue receiving - call receiveLoop again
                receiveLoop()
            }
        }
        
        // Start the receive loop
        receiveLoop()
        print("✅ Continuous receive handler started")
    }
    
    // MARK: - Frame Buffer Updates
    
    private func startReceivingUpdates() {
        print("🔄 Starting frame buffer update loop...")
        receiveTask = Task {
            var updateCount = 0
            while !Task.isCancelled && isConnected {
                do {
                    updateCount += 1
                    if updateCount % 10 == 0 {
                        print("🔄 Update loop iteration \(updateCount)")
                    }
                    try await requestFrameBufferUpdate()
                    try await readFrameBufferUpdate()
                } catch {
                    print("❌ Error receiving update: \(error)")
                    print("❌ Error details: \(error.localizedDescription)")
                    break
                }
            }
            print("🛑 Frame buffer update loop ended")
        }
    }
    
    private func requestFrameBufferUpdate() async throws {
        // Send FramebufferUpdateRequest message
        var message = Data()
        message.append(3) // Message type: FramebufferUpdateRequest
        message.append(1) // Incremental = true
        message.append(contentsOf: withUnsafeBytes(of: UInt16(0).bigEndian) { Data($0) }) // x
        message.append(contentsOf: withUnsafeBytes(of: UInt16(0).bigEndian) { Data($0) }) // y
        message.append(contentsOf: withUnsafeBytes(of: UInt16(0xFFFF).bigEndian) { Data($0) }) // width
        message.append(contentsOf: withUnsafeBytes(of: UInt16(0xFFFF).bigEndian) { Data($0) }) // height
        try await writeData(message)
    }
    
    private func readFrameBufferUpdate() async throws {
        // Read message type
        let messageType = try await readByte()
        guard messageType == 0 else {
            // Skip non-framebuffer-update messages
            print("⚠️ Received non-framebuffer message type: \(messageType)")
            return
        }
        
        // Read padding
        _ = try await readByte()
        
        // Read number of rectangles
        let numRects = try await readUInt16()
        if numRects > 1000 {
            print("⚠️ Suspicious number of rectangles: \(numRects), limiting to 1000")
            // Protocol might be desynced, but try to continue
        }
        let safeNumRects = min(numRects, 1000)
        print("📦 Received framebuffer update with \(numRects) rectangles (processing \(safeNumRects))")
        
        guard let fb = frameBuffer else {
            print("⚠️ Frame buffer is nil, skipping update")
            return
        }
        
        let fbSize = await fb.size
        var invalidRectCount = 0
        let maxInvalidRects = 10 // If we see too many invalid rectangles, protocol is desynced
        
        for i in 0..<safeNumRects {
            let x = try await readUInt16()
            let y = try await readUInt16()
            let width = try await readUInt16()
            let height = try await readUInt16()
            let encoding = try await readInt32()
            
            // Validate rectangle dimensions
            let rectWidth = Int(width)
            let rectHeight = Int(height)
            let rectX = Int(x)
            let rectY = Int(y)
            
            // Check for obviously invalid dimensions (likely protocol desync)
            if rectWidth > Int(fbSize.width) * 2 || rectHeight > Int(fbSize.height) * 2 || 
               rectWidth == 0 || rectHeight == 0 ||
               rectX > Int(fbSize.width) * 2 || rectY > Int(fbSize.height) * 2 {
                print("⚠️ Rectangle \(i): Invalid dimensions \(width)x\(height) at (\(x),\(y)), skipping")
                // Try to skip data based on encoding, but be conservative
                try await skipRectangleData(encoding: encoding, width: rectWidth, height: rectHeight)
                continue
            }
            
            // Validate encoding value (should be reasonable)
            // Valid encodings: 0-255 for standard, negative for pseudo-encodings
            // Large positive values suggest protocol desync
            if encoding > 255 && encoding > 0 {
                invalidRectCount += 1
                if invalidRectCount > maxInvalidRects {
                    print("⚠️ Too many invalid rectangles (\(invalidRectCount)), protocol desynced. Breaking update.")
                    // Break out - will try to resync on next update request
                    break
                }
                print("⚠️ Rectangle \(i): Invalid encoding value \(encoding) (likely protocol desync)")
                // Protocol is likely desynced - try to skip a reasonable amount and continue
                // This is a best-effort recovery
                let estimatedSkip = min(rectWidth * rectHeight * 4, 1_000_000)
                if estimatedSkip > 0 && estimatedSkip < 10_000_000 {
                    do {
                        _ = try await readData(count: estimatedSkip)
                    } catch {
                        print("⚠️ Failed to skip data, protocol may be desynced: \(error)")
                        // Break out of rectangle loop - will try to resync on next update
                        break
                    }
                }
                continue
            }
            
            // Reset invalid count on valid encoding
            invalidRectCount = 0
            
            print("  Rectangle \(i): \(width)x\(height) at (\(x),\(y)), encoding: \(encoding)")
            
            // Read pixel data based on encoding
            if encoding == 0 {
                // Raw encoding - read pixel data
                let pixelSize = 4 // Assume 32-bit pixels
                let dataSize = rectWidth * rectHeight * pixelSize
                
                // Safety check for data size
                if dataSize > 100_000_000 { // 100MB limit
                    print("⚠️ Rectangle \(i): Data size too large (\(dataSize) bytes), skipping")
                    continue
                }
                
                let pixelData = try await readData(count: dataSize)
                
                print("  📊 Updating frame buffer with \(dataSize) bytes")
                await fb.update(
                    rect: CGRect(x: rectX, y: rectY, width: rectWidth, height: rectHeight),
                    data: pixelData
                )
                
                // Update image - already on MainActor since class is @MainActor
                let newImage = await fb.toImage()
                if newImage != nil {
                    self.frameBufferImage = newImage
                }
            } else if encoding == 1 {
                // CopyRect encoding - copy from another location
                // Read source coordinates (2 bytes each)
                let sourceX = try await readUInt16()
                let sourceY = try await readUInt16()
                print("  📋 CopyRect: copying from (\(sourceX), \(sourceY))")
                
                // Perform copy operation in frame buffer
                await fb.copyRect(
                    from: CGRect(x: Int(sourceX), y: Int(sourceY), width: rectWidth, height: rectHeight),
                    to: CGRect(x: rectX, y: rectY, width: rectWidth, height: rectHeight)
                )
                
                // Update image
                let newImage = await fb.toImage()
                if newImage != nil {
                    self.frameBufferImage = newImage
                }
            } else {
                // Unsupported encoding - must skip the pixel data to keep protocol in sync
                print("⚠️ Unsupported encoding: \(encoding), skipping pixel data")
                do {
                    try await skipRectangleData(encoding: encoding, width: rectWidth, height: rectHeight)
                } catch {
                    print("⚠️ Failed to skip rectangle data: \(error)")
                    // If we can't skip, protocol is likely desynced
                    break
                }
            }
        }
    }
    
    private func skipRectangleData(encoding: Int32, width: Int, height: Int) async throws {
        // For unsupported encodings, we need to skip the pixel data
        // Most encodings have variable-length data, but we can make educated guesses
        
        // Common encodings and their data sizes:
        // - Raw (0): width * height * bytesPerPixel (already handled)
        // - CopyRect (1): 4 bytes (source x, y)
        // - RRE (2): variable (sub-rectangles)
        // - Hextile (5): variable (tiles)
        // - ZRLE (16): variable (compressed)
        // - Cursor pseudo-encoding (-239): variable
        // - DesktopSize pseudo-encoding (-223): 0 bytes
        
        switch encoding {
        case 1: // CopyRect
            _ = try await readData(count: 4) // Source x, y (2 bytes each)
        case -223: // DesktopSize pseudo-encoding
            // No data to skip
            break
        case -239: // Cursor pseudo-encoding
            // Cursor has variable data, but we can estimate
            // Skip cursor data: width * height * bytesPerPixel + mask data
            let cursorDataSize = width * height * 4 + ((width + 7) / 8) * height
            if cursorDataSize < 10_000_000 { // Safety limit
                _ = try await readData(count: cursorDataSize)
            }
        default:
            // For unknown encodings, try to estimate or skip conservatively
            // Many encodings are compressed, so we can't easily determine size
            // We'll try to read a reasonable amount and hope the next rectangle header is valid
            // This is a fallback - ideally we'd support more encodings
            print("⚠️ Unknown encoding \(encoding), attempting to skip data")
            // For compressed encodings, we can't easily determine size
            // We'll need to rely on the server sending proper data or implement encoding support
            // For now, try to read a small amount and see if we can resync
            // This is not ideal but better than hanging
            let estimatedSize = min(width * height * 4, 1_000_000) // Max 1MB estimate
            if estimatedSize > 0 && estimatedSize < 10_000_000 {
                _ = try await readData(count: estimatedSize)
            }
        }
    }
    
    // MARK: - Input
    
    func sendKey(key: UInt32, pressed: Bool) {
        Task {
            do {
                var message = Data()
                message.append(4) // Message type: KeyEvent
                message.append(pressed ? 1 : 0) // Down flag
                message.append(0) // Padding
                message.append(0) // Padding
                message.append(contentsOf: withUnsafeBytes(of: key.bigEndian) { Data($0) })
                try await writeData(message)
            } catch {
                print("❌ Error sending key: \(error)")
            }
        }
    }
    
    func sendMouse(x: Int, y: Int, buttonMask: UInt8) {
        Task {
            do {
                var message = Data()
                message.append(5) // Message type: PointerEvent
                message.append(buttonMask)
                message.append(contentsOf: withUnsafeBytes(of: UInt16(x).bigEndian) { Data($0) })
                message.append(contentsOf: withUnsafeBytes(of: UInt16(y).bigEndian) { Data($0) })
                try await writeData(message)
            } catch {
                print("❌ Error sending mouse: \(error)")
            }
        }
    }
    
    // MARK: - Data I/O
    
    nonisolated(unsafe) private var receiveBuffer: Data = Data()
    
    private func readData(count: Int) async throws -> Data {
        // Check if we already have enough data in the buffer
        if receiveBuffer.count >= count {
            let result = receiveBuffer.prefix(count)
            receiveBuffer.removeFirst(count)
            print("📦 Read \(count) bytes from buffer (remaining: \(receiveBuffer.count))")
            return Data(result)
        }
        
        print("📥 Reading \(count) bytes (have \(receiveBuffer.count) in buffer)")
        
        // Wait for data to arrive via continuous receive
        return try await withCheckedThrowingContinuation { continuation in
            // Check again in case data arrived between check and setting continuation
            if self.receiveBuffer.count >= count {
                let result = self.receiveBuffer.prefix(count)
                self.receiveBuffer.removeFirst(count)
                print("📦 Data available, resuming immediately")
                continuation.resume(returning: Data(result))
                return
            }
            
            let readID = UUID()
            self.currentReadID = readID
            self.dataAvailableContinuation = continuation
            self.pendingReadCount = count
            print("⏳ Waiting for \(count) bytes via continuous receive (buffer has \(self.receiveBuffer.count))...")
            
            // Set timeout - longer for ServerInit reads (width/height are 2 bytes each)
            Task {
                let timeoutDuration: UInt64 = count == 2 ? 10_000_000_000 : 5_000_000_000 // 10s for ServerInit, 5s for others
                try? await Task.sleep(nanoseconds: timeoutDuration)
                if self.currentReadID == readID {
                    self.dataAvailableContinuation = nil
                    self.pendingReadCount = 0
                    self.currentReadID = nil
                    print("⏱️ Read timeout after \(timeoutDuration / 1_000_000_000) seconds (waiting for \(count) bytes)")
                    continuation.resume(throwing: VNCError.timeout)
                }
            }
        }
    }
    
    private func readByte() async throws -> UInt8 {
        let data = try await readData(count: 1)
        return data[0]
    }
    
    private func readUInt16() async throws -> UInt16 {
        let data = try await readData(count: 2)
        return UInt16(data[0]) << 8 | UInt16(data[1])
    }
    
    private func readUInt32() async throws -> UInt32 {
        let data = try await readData(count: 4)
        return UInt32(data[0]) << 24 | UInt32(data[1]) << 16 | UInt32(data[2]) << 8 | UInt32(data[3])
    }
    
    private func readInt32() async throws -> Int32 {
        let data = try await readData(count: 4)
        return Int32(bitPattern: UInt32(data[0]) << 24 | UInt32(data[1]) << 16 | UInt32(data[2]) << 8 | UInt32(data[3]))
    }
    
    private func writeData(_ data: Data) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            connection?.send(content: data, completion: .contentProcessed { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            })
        }
    }
    
    private func writeByte(_ byte: UInt8) async throws {
        try await writeData(Data([byte]))
    }
}

// MARK: - Errors

enum VNCError: LocalizedError {
    case invalidProtocol
    case noSecurityTypes
    case vncAuthNotSupported
    case authenticationFailed
    case incompleteData
    case timeout
    
    var errorDescription: String? {
        switch self {
        case .invalidProtocol:
            return "Invalid RFB protocol version"
        case .noSecurityTypes:
            return "No security types available"
        case .vncAuthNotSupported:
            return "VNC Authentication not supported"
        case .authenticationFailed:
            return "VNC authentication failed"
        case .incompleteData:
            return "Incomplete data received"
        case .timeout:
            return "Connection timeout - server did not respond"
        }
    }
}

