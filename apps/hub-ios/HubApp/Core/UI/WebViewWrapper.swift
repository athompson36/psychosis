//
//  WebViewWrapper.swift
//  HubApp
//
//  Created on [Current Date]
//

import SwiftUI
import WebKit

struct WebViewWrapper: UIViewRepresentable {
    let url: URL?
    let username: String?
    let password: String?
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?
    var onScreenshot: ((WKWebView) -> Void)?
    
    init(
        url: URL?,
        username: String? = nil,
        password: String? = nil,
        isLoading: Binding<Bool>,
        errorMessage: Binding<String?>,
        onScreenshot: ((WKWebView) -> Void)? = nil
    ) {
        self.url = url
        self.username = username
        self.password = password
        self._isLoading = isLoading
        self._errorMessage = errorMessage
        self.onScreenshot = onScreenshot
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        
        // Configure for remote desktop interaction
        // Use modern API for JavaScript (iOS 14+)
        if #available(iOS 14.0, *) {
            let preferences = WKWebpagePreferences()
            preferences.allowsContentJavaScript = true
            config.defaultWebpagePreferences = preferences
        } else {
            config.preferences.javaScriptEnabled = true
        }
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        // Enable zoom and pan for remote desktop
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        context.coordinator.webView = webView
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        
        // Store webView reference for screenshot callback
        if let onScreenshot = self.onScreenshot {
            DispatchQueue.main.async {
                onScreenshot(webView)
            }
        }
        
        // Configure scroll view for better remote desktop interaction
        webView.scrollView.minimumZoomScale = 0.5
        webView.scrollView.maximumZoomScale = 3.0
        webView.scrollView.zoomScale = 1.0
        webView.scrollView.bouncesZoom = true
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.isPagingEnabled = false
        
        // Better touch handling for remote desktop
        webView.scrollView.delaysContentTouches = false
        webView.scrollView.canCancelContentTouches = true
        
        // Hide scroll indicators for native look
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.showsVerticalScrollIndicator = false
        
        // Remove background color for seamless native appearance
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        
        // Add gesture recognizers for better interaction
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
        webView.addGestureRecognizer(pinchGesture)
        
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        webView.addGestureRecognizer(panGesture)
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Reset tracking if URL is nil (disconnected)
        if url == nil {
            context.coordinator.lastLoadedURL = nil
            context.coordinator.isCurrentlyLoading = false
            return
        }
        
        // Only load if URL has changed and we're not currently loading
        guard let url = url,
              url != context.coordinator.lastLoadedURL,
              !context.coordinator.isCurrentlyLoading else {
            return
        }
        
        var request = URLRequest(url: url)
        
        // Handle basic authentication if credentials are in URL
        if let user = url.user, let password = url.password {
            let loginString = "\(user):\(password)"
            let loginData = loginString.data(using: .utf8)!
            let base64LoginString = loginData.base64EncodedString()
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        }
        
        // Set additional headers for better compatibility with noVNC
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("en-US,en;q=0.9", forHTTPHeaderField: "Accept-Language")
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")
        
        // Increase timeout for remote desktop connections
        request.timeoutInterval = 30.0
        
        // Allow redirects
        request.httpShouldHandleCookies = true
        
        // Mark as loading and store URL
        context.coordinator.isCurrentlyLoading = true
        context.coordinator.lastLoadedURL = url
        
        webView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        let parent: WebViewWrapper
        var webView: WKWebView?
        var lastLoadedURL: URL?
        var isCurrentlyLoading: Bool = false
        
        init(_ parent: WebViewWrapper) {
            self.parent = parent
        }
        
        func injectText(_ text: String) {
            guard let webView = webView else { return }
            
            // Escape the text for JavaScript
            let escapedText = text
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "\"", with: "\\\"")
                .replacingOccurrences(of: "\n", with: "\\n")
                .replacingOccurrences(of: "\r", with: "\\r")
            
            // Inject text by simulating keyboard events
            let script = """
                (function() {
                    var activeElement = document.activeElement;
                    if (activeElement && (activeElement.tagName === 'INPUT' || activeElement.tagName === 'TEXTAREA' || activeElement.isContentEditable)) {
                        // For input/textarea/contentEditable elements
                        var event = new KeyboardEvent('keydown', { bubbles: true, cancelable: true });
                        activeElement.dispatchEvent(event);
                        
                        if (activeElement.tagName === 'INPUT' || activeElement.tagName === 'TEXTAREA') {
                            activeElement.value += '\(escapedText)';
                        } else {
                            activeElement.textContent += '\(escapedText)';
                        }
                        
                        var inputEvent = new Event('input', { bubbles: true });
                        activeElement.dispatchEvent(inputEvent);
                        
                        var changeEvent = new Event('change', { bubbles: true });
                        activeElement.dispatchEvent(changeEvent);
                    } else {
                        // Try to find and focus the first input element
                        var input = document.querySelector('input, textarea, [contenteditable="true"]');
                        if (input) {
                            input.focus();
                            if (input.tagName === 'INPUT' || input.tagName === 'TEXTAREA') {
                                input.value += '\(escapedText)';
                            } else {
                                input.textContent += '\(escapedText)';
                            }
                            var event = new Event('input', { bubbles: true });
                            input.dispatchEvent(event);
                        }
                    }
                })();
            """
            
            webView.evaluateJavaScript(script) { result, error in
                if let error = error {
                    print("Error injecting text: \(error.localizedDescription)")
                }
            }
        }
        
        func sendKey(_ key: String) {
            guard let webView = webView else { return }
            
            let keyCode: String
            let keyName: String
            var modifiers: [String] = []
            
            switch key {
            case "Enter":
                keyCode = "13"
                keyName = "Enter"
            case "Tab":
                keyCode = "9"
                keyName = "Tab"
            case "Esc", "Escape":
                keyCode = "27"
                keyName = "Escape"
            case "Ctrl+C":
                keyCode = "67"
                keyName = "c"
                modifiers.append("ctrlKey")
            case "Ctrl+V":
                keyCode = "86"
                keyName = "v"
                modifiers.append("ctrlKey")
            case "Ctrl+Z":
                keyCode = "90"
                keyName = "z"
                modifiers.append("ctrlKey")
            case "Ctrl+S":
                keyCode = "83"
                keyName = "s"
                modifiers.append("ctrlKey")
            default:
                return
            }
            
            let modString = modifiers.isEmpty ? "false" : modifiers.joined(separator: ", ")
            
            let script = """
                (function() {
                    var activeElement = document.activeElement || document.body;
                    var keyEvent = new KeyboardEvent('keydown', {
                        key: '\(keyName)',
                        code: '\(keyName)',
                        keyCode: \(keyCode),
                        which: \(keyCode),
                        bubbles: true,
                        cancelable: true,
                        ctrlKey: \(modifiers.contains("ctrlKey") ? "true" : "false"),
                        shiftKey: false,
                        altKey: false,
                        metaKey: false
                    });
                    activeElement.dispatchEvent(keyEvent);
                    
                    var keyUpEvent = new KeyboardEvent('keyup', {
                        key: '\(keyName)',
                        code: '\(keyName)',
                        keyCode: \(keyCode),
                        which: \(keyCode),
                        bubbles: true,
                        cancelable: true,
                        ctrlKey: \(modifiers.contains("ctrlKey") ? "true" : "false"),
                        shiftKey: false,
                        altKey: false,
                        metaKey: false
                    });
                    activeElement.dispatchEvent(keyUpEvent);
                })();
            """
            
            webView.evaluateJavaScript(script) { result, error in
                if let error = error {
                    print("Error sending key: \(error.localizedDescription)")
                }
            }
        }
        
        func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            // Handle authentication challenge
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic ||
               challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPDigest {
                
                if let username = parent.username, let password = parent.password {
                    let credential = URLCredential(user: username, password: password, persistence: .forSession)
                    completionHandler(.useCredential, credential)
                    return
                }
            }
            
            // Default: cancel authentication challenge
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
            parent.errorMessage = nil
            isCurrentlyLoading = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            isCurrentlyLoading = false
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            isCurrentlyLoading = false
            
            // Ignore -999 errors (NSURLErrorCancelled) - these are harmless navigation cancellations
            let nsError = error as NSError
            if nsError.code == -999 { // NSURLErrorCancelled
                // This is a cancelled navigation, usually harmless (e.g., new navigation started)
                return
            }
            
            parent.isLoading = false
            parent.errorMessage = error.localizedDescription
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            isCurrentlyLoading = false
            
            // Ignore -999 errors (NSURLErrorCancelled) - these are harmless navigation cancellations
            let nsError = error as NSError
            if nsError.code == -999 { // NSURLErrorCancelled
                // This is a cancelled navigation, usually harmless (e.g., new navigation started)
                return
            }
            
            parent.isLoading = false
            parent.errorMessage = error.localizedDescription
        }
        
        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            guard let webView = webView else { return }
            
            if gesture.state == .changed {
                let scale = gesture.scale
                let currentScale = webView.scrollView.zoomScale
                let newScale = currentScale * scale
                
                let clampedScale = min(max(newScale, webView.scrollView.minimumZoomScale), webView.scrollView.maximumZoomScale)
                webView.scrollView.setZoomScale(clampedScale, animated: false)
                
                gesture.scale = 1.0
            }
        }
        
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let webView = webView else { return }
            
            if gesture.state == .began || gesture.state == .changed {
                let translation = gesture.translation(in: webView)
                let currentOffset = webView.scrollView.contentOffset
                let newOffset = CGPoint(
                    x: currentOffset.x - translation.x,
                    y: currentOffset.y - translation.y
                )
                
                webView.scrollView.setContentOffset(newOffset, animated: false)
                gesture.setTranslation(.zero, in: webView)
            }
        }
    }
}

