//
//  WebViewWrapper.swift
//  SmartScrollApp
//
//  Created by oniel rosario on 10/2/25.
//  Copyright © 2025 Oniel Rosario. All rights reserved.
//

import SwiftUI
import WebKit

struct WebViewWrapper: UIViewRepresentable {
    let url: URL
    
    @Binding var behavior: ScrollBehavior
    var scrollStep: CGFloat = 80
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.allowsBackForwardNavigationGestures = true
        context.coordinator.webView = webView
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if behavior != .none {
            context.coordinator.apply(behavior: behavior, step: scrollStep)
            DispatchQueue.main.async {
                self.behavior = .none
            }
        }
    }
    
    final class Coordinator: NSObject {
        var parent: WebViewWrapper
        weak var webView: WKWebView?
        
        init(_ parent: WebViewWrapper) {
            self.parent = parent
        }
        
        func apply(behavior: ScrollBehavior, step: CGFloat) {
            guard let webView else { return }
            
            switch behavior {
            case .scrollUp:
                let y = max(0, webView.scrollView.contentOffset.y - step)
                webView.scrollView.setContentOffset(CGPoint(x: 0, y: y), animated: true)
            case .scrollDown:
                let maxY = max(0, webView.scrollView.contentSize.height - webView.scrollView.bounds.height)
                let y = min(maxY, webView.scrollView.contentOffset.y + step)
                webView.scrollView.setContentOffset(CGPoint(x: 0, y: y), animated: true)
            case .leftBlink:
                if webView.canGoBack { webView.goBack() }
            case .rightBlink:
                if webView.canGoForward { webView.goForward() }
            case .none:
                break
            }
        }
    }
}
