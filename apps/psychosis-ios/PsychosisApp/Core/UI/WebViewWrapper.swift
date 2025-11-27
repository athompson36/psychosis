//
//  WebViewWrapper.swift
//  PsychosisApp
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
    var selectedPane: CursorPane?
    var onScreenshot: ((WKWebView) -> Void)?
    
    init(
        url: URL?,
        username: String? = nil,
        password: String? = nil,
        isLoading: Binding<Bool>,
        errorMessage: Binding<String?>,
        selectedPane: CursorPane? = nil,
        onScreenshot: ((WKWebView) -> Void)? = nil
    ) {
        self.url = url
        self.username = username
        self.password = password
        self._isLoading = isLoading
        self._errorMessage = errorMessage
        self.selectedPane = selectedPane
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
        
        // Add user script to capture RFB instance and enable all keyboard passthrough
        let rfbCaptureScript = """
            (function() {
                // Function to enable full keyboard passthrough on RFB instance
                function enableFullKeyboard(rfb) {
                    if (!rfb) return;
                    
                    console.log('🔧 Enabling full keyboard passthrough on RFB instance');
                    
                    // Enable all keys - critical for Ctrl+Shift combos
                    if (rfb.keyboard && typeof rfb.keyboard.setAllKeysAllowed === 'function') {
                        rfb.keyboard.setAllKeysAllowed(true);
                        console.log('✅ rfb.keyboard.setAllKeysAllowed(true)');
                    }
                    
                    // Enable focus on click
                    if (typeof rfb.focusOnClick !== 'undefined') {
                        rfb.focusOnClick = true;
                        console.log('✅ rfb.focusOnClick = true');
                    }
                    
                    // Disable view-only mode
                    if (typeof rfb.viewOnly !== 'undefined') {
                        rfb.viewOnly = false;
                        console.log('✅ rfb.viewOnly = false');
                    }
                    
                    // Enable clipboard
                    if (typeof rfb.clipViewport !== 'undefined') {
                        rfb.clipViewport = true;
                    }
                    
                    // Try to focus the canvas
                    if (rfb._target) {
                        rfb._target.focus();
                        console.log('✅ Focused RFB target canvas');
                    }
                    
                    // Mark as configured
                    rfb._psychosisConfigured = true;
                }
                
                // Override RFB constructor to capture all instances
                if (typeof window.RFB === 'function') {
                    var OriginalRFB = window.RFB;
                    window.RFB = function() {
                        var instance = OriginalRFB.apply(this, arguments);
                        console.log('🎯 Captured RFB instance via constructor override');
                        window.psychosisRFB = instance;
                        if (!window.rfb) window.rfb = instance;
                        
                        // Enable keyboard immediately
                        setTimeout(function() {
                            enableFullKeyboard(instance);
                        }, 100);
                        
                        return instance;
                    };
                    window.RFB.prototype = OriginalRFB.prototype;
                }
                
                // Watch for rfb assignment using Proxy (if available)
                try {
                    var rfbProxy = new Proxy({}, {
                        set: function(target, prop, value) {
                            if (prop === 'rfb' && value && typeof value.sendKey === 'function') {
                                console.log('🎯 RFB assigned via Proxy');
                                window.psychosisRFB = value;
                                enableFullKeyboard(value);
                            }
                            target[prop] = value;
                            return true;
                        }
                    });
                } catch(e) {}
                
                // Also check periodically for RFB instance after page load
                var checkCount = 0;
                var checkInterval = setInterval(function() {
                    checkCount++;
                    var rfb = window.psychosisRFB || window.rfb || (typeof UI !== 'undefined' && UI.rfb);
                    
                    if (rfb && !rfb._psychosisConfigured) {
                        console.log('🎯 Found RFB instance on check #' + checkCount);
                        window.psychosisRFB = rfb;
                        enableFullKeyboard(rfb);
                        clearInterval(checkInterval);
                    }
                    
                    // Stop after 30 seconds
                    if (checkCount > 60) {
                        clearInterval(checkInterval);
                        console.log('⚠️ Stopped looking for RFB instance after 30s');
                    }
                }, 500);
            })();
        """
        let userScript = WKUserScript(source: rfbCaptureScript, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        config.userContentController.addUserScript(userScript)
        
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
        
        // Enable keyboard interaction
        webView.scrollView.keyboardDismissMode = .interactive
        
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
        // Update pane selection if changed
        if let pane = selectedPane, webView.url != nil {
            context.coordinator.updatePaneSelection(pane)
        }
        
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
            
            // Wait a bit for noVNC to initialize, then inject RFB finder
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.injectRFBFinder(webView: webView)
            }
        }
        
        func injectRFBFinder(webView: WKWebView) {
            // Inject script to enable keyboard input and find RFB instance
            let rfbSetupScript = """
                (function() {
                    // First, ensure keyboard input is enabled on the page
                    console.log('🔍 Enabling keyboard input and finding RFB...');
                    
                    // Make canvas interactive and focusable
                    function setupCanvas() {
                        var canvas = document.querySelector('canvas');
                        if (canvas) {
                            canvas.setAttribute('tabindex', '0');
                            canvas.setAttribute('contenteditable', 'true');
                            canvas.style.outline = 'none';
                            canvas.style.cursor = 'default';
                            
                            // Add keyboard event listeners directly to canvas
                            canvas.addEventListener('keydown', function(e) {
                                console.log('Canvas keydown:', e.key, e.code);
                            }, true);
                            
                            canvas.addEventListener('keyup', function(e) {
                                console.log('Canvas keyup:', e.key, e.code);
                            }, true);
                            
                            // Focus canvas when clicked
                            canvas.addEventListener('click', function() {
                                canvas.focus();
                                console.log('Canvas focused');
                            });
                            
                            console.log('✅ Canvas set up for keyboard input');
                            return canvas;
                        }
                        return null;
                    }
                    
                    // Set up canvas immediately
                    var canvas = setupCanvas();
                    
                    // Also watch for canvas creation
                    var observer = new MutationObserver(function(mutations) {
                        if (!canvas) {
                            canvas = setupCanvas();
                        }
                    });
                    observer.observe(document.body || document.documentElement, {
                        childList: true,
                        subtree: true
                    });
                    
                    // Try to focus canvas after a delay
                    setTimeout(function() {
                        if (canvas) {
                            canvas.focus();
                            canvas.click();
                        }
                    }, 1000);
                })();
                
                (function() {
                    console.log('🔍 Setting up RFB finder (v2)...');
                    
                    // Function to find RFB instance using multiple methods
                    function findRFB() {
                        // Method 1: Direct window property (most common)
                        if (window.rfb && typeof window.rfb.sendKey === 'function') {
                            console.log('✅ Found RFB at window.rfb');
                            return window.rfb;
                        }
                        
                        // Method 2: UI object (noVNC UI wrapper)
                        if (typeof UI !== 'undefined') {
                            if (UI.rfb && typeof UI.rfb.sendKey === 'function') {
                                console.log('✅ Found RFB at UI.rfb');
                                return UI.rfb;
                            }
                            // Check UI._rfb
                            if (UI._rfb && typeof UI._rfb.sendKey === 'function') {
                                console.log('✅ Found RFB at UI._rfb');
                                return UI._rfb;
                            }
                        }
                        
                        // Method 3: Check iframes (noVNC might load in an iframe)
                        var iframes = document.querySelectorAll('iframe');
                        for (var i = 0; i < iframes.length; i++) {
                            try {
                                var iframe = iframes[i];
                                var iframeWindow = iframe.contentWindow;
                                if (iframeWindow) {
                                    if (iframeWindow.rfb && typeof iframeWindow.rfb.sendKey === 'function') {
                                        console.log('✅ Found RFB in iframe');
                                        return iframeWindow.rfb;
                                    }
                                    if (iframeWindow.UI && iframeWindow.UI.rfb) {
                                        console.log('✅ Found RFB in iframe UI');
                                        return iframeWindow.UI.rfb;
                                    }
                                }
                            } catch(e) {
                                // Cross-origin iframe, can't access
                            }
                        }
                        
                        // Method 4: Look for RFB in all window properties
                        for (var key in window) {
                            try {
                                var obj = window[key];
                                if (obj && typeof obj === 'object' && typeof obj.sendKey === 'function') {
                                    // Check if it looks like an RFB object
                                    if (obj._target || obj._rfb_connection || obj.sendCtrlAltDel || obj._display || obj._canvas) {
                                        console.log('✅ Found RFB-like object at window.' + key);
                                        return obj;
                                    }
                                }
                            } catch(e) {}
                        }
                        
                        // Method 5: Canvas element
                        var canvas = document.querySelector('canvas');
                        if (canvas) {
                            if (canvas.rfb && typeof canvas.rfb.sendKey === 'function') {
                                console.log('✅ Found RFB at canvas.rfb');
                                return canvas.rfb;
                            }
                            // Check all parent elements
                            var parent = canvas.parentElement;
                            var depth = 0;
                            while (parent && depth < 5) {
                                if (parent.rfb && typeof parent.rfb.sendKey === 'function') {
                                    console.log('✅ Found RFB at canvas parent (depth ' + depth + ')');
                                    return parent.rfb;
                                }
                                parent = parent.parentElement;
                                depth++;
                            }
                        }
                        
                        return null;
                    }
                    
                    // Hook into noVNC's RFB creation
                    var originalRFB = window.RFB;
                    if (typeof window.RFB === 'function') {
                        window.RFB = function() {
                            var instance = originalRFB.apply(this, arguments);
                            console.log('✅ Captured RFB instance from constructor');
                            window.psychosisRFB = instance;
                            // Enable keyboard passthrough after a brief delay
                            setTimeout(function() {
                                enableFullKeyboard(instance);
                            }, 100);
                            return instance;
                        };
                        window.RFB.prototype = originalRFB.prototype;
                    }
                    
                    // Use MutationObserver to watch for RFB creation
                    var observer = new MutationObserver(function(mutations) {
                        if (!window.psychosisRFB) {
                            window.psychosisRFB = findRFB();
                            if (window.psychosisRFB) {
                                console.log('✅ Found RFB via MutationObserver');
                                enableFullKeyboard(window.psychosisRFB);
                                observer.disconnect();
                            }
                        }
                    });
                    
                    // Observe the entire document
                    observer.observe(document.body || document.documentElement, {
                        childList: true,
                        subtree: true,
                        attributes: true,
                        attributeFilter: ['class', 'id']
                    });
                    
                    // Function to enable full keyboard passthrough
                    function enableFullKeyboard(rfb) {
                        if (!rfb || rfb._psychosisConfigured) return;
                        
                        console.log('🔧 Enabling full keyboard passthrough on RFB instance');
                        
                        // CRITICAL: Enable all keys - fixes Ctrl+Shift combos
                        if (rfb.keyboard && typeof rfb.keyboard.setAllKeysAllowed === 'function') {
                            rfb.keyboard.setAllKeysAllowed(true);
                            console.log('✅ rfb.keyboard.setAllKeysAllowed(true)');
                        }
                        
                        // Also try _keyboard (private property)
                        if (rfb._keyboard && typeof rfb._keyboard.setAllKeysAllowed === 'function') {
                            rfb._keyboard.setAllKeysAllowed(true);
                            console.log('✅ rfb._keyboard.setAllKeysAllowed(true)');
                        }
                        
                        // Enable focus on click
                        if (typeof rfb.focusOnClick !== 'undefined') {
                            rfb.focusOnClick = true;
                            console.log('✅ rfb.focusOnClick = true');
                        }
                        
                        // Disable view-only mode
                        if (typeof rfb.viewOnly !== 'undefined') {
                            rfb.viewOnly = false;
                            console.log('✅ rfb.viewOnly = false');
                        }
                        
                        // Enable clipboard
                        if (typeof rfb.clipViewport !== 'undefined') {
                            rfb.clipViewport = true;
                        }
                        
                        // Try to focus the canvas/target
                        if (rfb._target) {
                            rfb._target.focus();
                            console.log('✅ Focused RFB target canvas');
                        }
                        
                        // Mark as configured
                        rfb._psychosisConfigured = true;
                    }
                    
                    // Try to find RFB immediately
                    window.psychosisRFB = findRFB();
                    if (window.psychosisRFB) {
                        console.log('✅ RFB instance found immediately');
                        enableFullKeyboard(window.psychosisRFB);
                        observer.disconnect();
                    }
                    
                    // Also set up interval watcher
                    var attempts = 0;
                    var maxAttempts = 60; // 30 seconds
                    var checkInterval = setInterval(function() {
                        attempts++;
                        if (!window.psychosisRFB) {
                            window.psychosisRFB = findRFB();
                            if (window.psychosisRFB) {
                                clearInterval(checkInterval);
                                observer.disconnect();
                                console.log('✅ Found noVNC RFB instance after ' + attempts + ' attempts');
                                enableFullKeyboard(window.psychosisRFB);
                            }
                        } else {
                            // RFB exists but may not be configured yet
                            if (!window.psychosisRFB._psychosisConfigured) {
                                enableFullKeyboard(window.psychosisRFB);
                            }
                            clearInterval(checkInterval);
                            observer.disconnect();
                        }
                        
                        if (attempts >= maxAttempts) {
                            clearInterval(checkInterval);
                            observer.disconnect();
                            if (!window.psychosisRFB) {
                                console.warn('⚠️ Could not find noVNC RFB instance');
                                console.log('All window keys:', Object.keys(window).slice(0, 30));
                                var vncKeys = Object.keys(window).filter(k => {
                                    var lower = k.toLowerCase();
                                    return lower.includes('rfb') || lower.includes('vnc') || lower.includes('novnc') || lower.includes('ui');
                                });
                                console.log('VNC-related keys:', vncKeys.length > 0 ? vncKeys : 'none found');
                                
                                // Try to find any object with sendKey
                                var sendKeyObjects = [];
                                for (var key in window) {
                                    try {
                                        var obj = window[key];
                                        if (obj && typeof obj === 'object' && typeof obj.sendKey === 'function') {
                                            sendKeyObjects.push(key);
                                        }
                                    } catch(e) {}
                                }
                                console.log('Objects with sendKey:', sendKeyObjects);
                            }
                        }
                    }, 500);
                })();
            """
            
            webView.evaluateJavaScript(rfbSetupScript) { result, error in
                if let error = error {
                    print("⚠️ Error setting up RFB finder: \(error.localizedDescription)")
                } else {
                    print("✅ RFB finder script injected (v2)")
                }
            }
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
        
        func updatePaneSelection(_ pane: CursorPane) {
            // Pane switching via VNC keyboard shortcuts is handled in RemoteDesktopView.showPane()
            // noVNC renders the remote desktop as a canvas, so DOM manipulation doesn't work.
            print("Pane selection: \(pane.rawValue) - VNC shortcuts sent from RemoteDesktopView")
        }
    }
}

