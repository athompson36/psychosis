//
//  NativeVNCView.swift
//  PsychosisApp
//
//  SwiftUI view for displaying native VNC connection
//

import SwiftUI

struct NativeVNCView: View {
    @ObservedObject var connection: VNCConnection
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastScale: CGFloat = 1.0
    @State private var lastOffset: CGSize = .zero
    @State private var image: UIImage?
    @State private var initialScaleCalculated: Bool = false
    @State private var imageSize: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let image = image {
                    // Fill the entire screen (stretch to fit)
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: geometry.size.width * scale, height: geometry.size.height * scale)
                        .offset(offset)
                        .clipped()
                    .gesture(
                        SimultaneousGesture(
                            // Pinch to zoom
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = lastScale * value
                                }
                                .onEnded { value in
                                    lastScale = scale
                                    // Clamp scale
                                    if scale < 0.5 { scale = 0.5; lastScale = 0.5 }
                                    if scale > 3.0 { scale = 3.0; lastScale = 3.0 }
                                },
                            // Drag to pan
                            DragGesture()
                                .onChanged { value in
                                    offset = CGSize(
                                        width: lastOffset.width + value.translation.width,
                                        height: lastOffset.height + value.translation.height
                                    )
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                }
                        )
                    )
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { value in
                                handleTap(at: value.location, in: geometry.size)
                            }
                    )
                    .simultaneousGesture(
                        LongPressGesture(minimumDuration: 0.5)
                            .onEnded { _ in
                                handleLongPress(at: offset)
                            }
                    )
                } else {
                    // Loading or disconnected state
                    if connection.isConnecting {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)
                            Text("Connecting...")
                                .foregroundColor(.white)
                        }
                    } else if let error = connection.errorMessage {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.title)
                                .foregroundColor(.red)
                            Text("Connection Error")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "display")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                            Text("Not Connected")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .onChange(of: connection.frameBufferImage) { oldImage, newImage in
            if let newImage = newImage {
                image = newImage
                imageSize = newImage.size
                
                // Calculate initial scale to fit screen on first image
                if !initialScaleCalculated {
                    calculateInitialScale(imageSize: newImage.size)
                    initialScaleCalculated = true
                }
            } else {
                image = nil
                initialScaleCalculated = false
            }
        }
        .onChange(of: connection.isConnected) { oldValue, newValue in
            print("🔌 Connection status changed: \(newValue)")
            if !newValue {
                image = nil
                initialScaleCalculated = false
            }
        }
    }
    
    // MARK: - Scaling
    
    private func calculateInitialScale(imageSize: CGSize) {
        // Don't apply additional scaling - let aspectRatio(.fit) handle it
        // Start with scale 1.0 so the image displays at its natural fit size
        scale = 1.0
        lastScale = 1.0
        offset = .zero
        lastOffset = .zero
        
        let screenSize = UIScreen.main.bounds.size
        print("📐 Image size: \(imageSize.width)x\(imageSize.height), screen: \(screenSize.width)x\(screenSize.height), initial scale: 1.0")
    }
    
    // MARK: - Image Updates
    // Image updates are handled via connection.frameBufferImage @Published property
    // No need for separate update task - VNCConnection updates frameBufferImage directly
    
    // MARK: - Input Handling
    
    private func handleTap(at location: CGPoint, in viewSize: CGSize) {
        guard let frameBuffer = connection.frameBuffer,
              let image = image else {
            print("⚠️ Cannot handle tap - no frame buffer or image")
            return
        }
        
        Task {
            // Get VNC frame buffer size
            let vncSize = await frameBuffer.size
            
            // Calculate the displayed image size (full screen fill mode)
            let displayedWidth = viewSize.width * scale
            let displayedHeight = viewSize.height * scale
            
            // Calculate position relative to image (accounting for pan offset)
            let relativeX = location.x - offset.width
            let relativeY = location.y - offset.height
            
            // Convert to VNC coordinates
            let vncX = Int((relativeX / displayedWidth) * vncSize.width)
            let vncY = Int((relativeY / displayedHeight) * vncSize.height)
            
            // Clamp to valid VNC coordinates
            let clampedX = max(0, min(vncX, Int(vncSize.width) - 1))
            let clampedY = max(0, min(vncY, Int(vncSize.height) - 1))
            
            print("🖱️ Tap at screen (\(Int(location.x)), \(Int(location.y))) -> VNC (\(clampedX), \(clampedY))")
            
            // Send mouse click (button 1 = left click)
            connection.sendMouse(x: clampedX, y: clampedY, buttonMask: 1)
            
            // Release after short delay
            try? await Task.sleep(nanoseconds: 50_000_000) // 50ms
            connection.sendMouse(x: clampedX, y: clampedY, buttonMask: 0)
        }
    }
    
    private func handleLongPress(at location: CGSize) {
        guard let frameBuffer = connection.frameBuffer else { return }
        
        // Right click (button 2) - TODO: implement proper location calculation
        Task {
            let vncSize = await frameBuffer.size
            // For now, send right click at center
            let vncX = Int(vncSize.width / 2)
            let vncY = Int(vncSize.height / 2)
            connection.sendMouse(x: vncX, y: vncY, buttonMask: 2)
            try? await Task.sleep(nanoseconds: 50_000_000)
            connection.sendMouse(x: vncX, y: vncY, buttonMask: 0)
        }
    }
}

