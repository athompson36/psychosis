//
//  ScreenshotManager.swift
//  PsychosisApp
//
//  Created on [Current Date]
//

import UIKit
import SwiftUI
import WebKit

class ScreenshotManager {
    static let shared = ScreenshotManager()
    
    private init() {}
    
    func captureWebView(_ webView: WKWebView) async -> UIImage? {
        return await MainActor.run {
            // Capture WebView content
            UIGraphicsBeginImageContextWithOptions(webView.bounds.size, false, UIScreen.main.scale)
            defer { UIGraphicsEndImageContext() }
            
            guard let context = UIGraphicsGetCurrentContext() else { return nil }
            webView.layer.render(in: context)
            
            return UIGraphicsGetImageFromCurrentImageContext()
        }
    }
    
    func saveImageToPhotos(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    func shareImage(_ image: UIImage, from viewController: UIViewController) {
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        viewController.present(activityVC, animated: true)
    }
}

