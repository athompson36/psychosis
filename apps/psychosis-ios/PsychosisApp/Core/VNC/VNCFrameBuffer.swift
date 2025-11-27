//
//  VNCFrameBuffer.swift
//  PsychosisApp
//
//  Frame buffer for VNC display
//

import Foundation
import UIKit
import CoreGraphics

actor VNCFrameBuffer {
    private var pixelData: [UInt8]
    private let width: Int
    private let height: Int
    private let bytesPerPixel = 4 // RGBA
    
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        self.pixelData = Array(repeating: 0, count: width * height * bytesPerPixel)
    }
    
    func update(rect: CGRect, data: Data) {
        let x = Int(rect.origin.x)
        let y = Int(rect.origin.y)
        let w = Int(rect.width)
        let h = Int(rect.height)
        
        // Ensure bounds
        guard x >= 0, y >= 0, x + w <= width, y + h <= height else {
            print("⚠️ Frame buffer update out of bounds: \(rect)")
            return
        }
        
        // Copy pixel data
        var dataIndex = 0
        for row in y..<(y + h) {
            for col in x..<(x + w) {
                let pixelIndex = (row * width + col) * bytesPerPixel
                
                if dataIndex + 3 < data.count {
                    // VNC sends pixels in format: R, G, B, (padding)
                    // Convert to RGBA
                    pixelData[pixelIndex] = data[dataIndex]     // R
                    pixelData[pixelIndex + 1] = data[dataIndex + 1] // G
                    pixelData[pixelIndex + 2] = data[dataIndex + 2] // B
                    pixelData[pixelIndex + 3] = 255 // A (opaque)
                    dataIndex += 4
                }
            }
        }
    }
    
    func toImage() -> UIImage? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue)
        
        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * bytesPerPixel,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else {
            return nil
        }
        
        guard let cgImage = context.makeImage() else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    var size: CGSize {
        CGSize(width: width, height: height)
    }
}


