//
//  ContentView.swift
//  SmartScrollApp
//
//  Created by oniel rosario on 10/2/25.
//  Copyright © 2025 Oniel Rosario. All rights reserved.
//

import SwiftUI
import WebKit

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel(url: "https://www.google.com")
    @State private var position = ScrollPosition()
    
    
    var body: some View {
        VStack {
            if #available(iOS 26.0, *) {
                WebView(url: viewModel.url)
                    .webViewScrollPosition($position)
                    
            } else {
                WebViewWrapper(url: viewModel.url, behavior: $viewModel.scrollBehavior)
            }
        }
        .onChange(of: viewModel.scrollBehavior) {
           switch viewModel.scrollBehavior {
                case .scrollDown:
               position.scrollTo(x: 0, y: 25)
           case .scrollUp:
               position.scrollTo(x: 0, y: -25)
           case .leftBlink:
               print("left blink")
           case .rightBlink:
               print("right block")
           case .none:
               print("none")
           }
        }
    }
}

#Preview {
    ContentView()
}
