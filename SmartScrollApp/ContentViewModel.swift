//
//  ContentViewModel.swift
//  SmartScrollApp
//
//  Created by oniel rosario on 10/2/25.
//  Copyright © 2025 Oniel Rosario. All rights reserved.
//

import ARKit

final class ContentViewModel: NSObject, ObservableObject {
    @Published var scrollBehavior: ScrollBehavior = .none
    
    let url: URL
    var session: ARSession
    
    private var lastEmit = Date.distantPast
    private let minInterval: TimeInterval = 0.12
    
    init(url: String,
         session: ARSession = ARSession()) {
        self.session = session
        self.url = URL(string: url) ?? URL(string: "https://www.google.com")!
        super.init()
    }
    
    
    func setupSession() {
        guard ARFaceTrackingConfiguration.isSupported else { return }
        session.delegate = self
        let configuration = ARFaceTrackingConfiguration()
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func stopSession() {
        session.pause()
    }
}

extension ContentViewModel: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let faceAnchor = anchors.first as? ARFaceAnchor else { return }
        
        let blendShape = faceAnchor.blendShapes
       
        guard let lookUpLeft = blendShape[.eyeLookUpLeft] as? Float ,
              let lookDown = blendShape[.eyeLookDownRight] as? Float ,
              let leftBlink = blendShape[.eyeBlinkLeft] as? Double ,
              let rightBlink = blendShape[.eyeBlinkRight] as? Double else {
            return
        }
        
        var next: ScrollBehavior = .none

        if lookUpLeft >= 0.010 {
            next = .scrollUp
        } else if lookDown >= 0.010 {
            next = .scrollDown
        }
        if leftBlink >= 0.010 {
            next = .leftBlink

        } else if rightBlink >= 0.010 {
            next = .rightBlink
        }
        
        let now = Date()
        guard now.timeIntervalSince(lastEmit) >= minInterval,
              next != .none else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.scrollBehavior = next
        }
    }
}

enum ScrollBehavior {
    case scrollUp
    case scrollDown
    case leftBlink
    case rightBlink
    case none
}
