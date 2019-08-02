//
//  ViewController.swift
//  SmartScrollApp
//
//  Created by Oniel Rosario on 8/1/19.
//  Copyright © 2019 Oniel Rosario. All rights reserved.
//

import UIKit
import ARKit
import WebKit

class MainViewController: UIViewController {
    var wkWebview = WKWebView()
    var session: ARSession!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAR()
       setupContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    private func setupAR() {
        session = ARSession()
        session.delegate = self
    }
    
    private func setupContent() {
        wkWebview.allowsBackForwardNavigationGestures = true
        let url = URL(string: "https://www.google.com/")
        wkWebview.load(URLRequest(url: url!))
        view = wkWebview
    }
}

extension MainViewController: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        if let faceAnchor = anchors.first as? ARFaceAnchor {
            Scroll(withFaceAnchor: faceAnchor)
        }
    }
    
    func Scroll(withFaceAnchor faceAnchor: ARFaceAnchor) {
        var blendShape: [ARFaceAnchor.BlendShapeLocation: Any] = faceAnchor.blendShapes
        guard let lookupScrollLeft = blendShape[.eyeLookUpLeft] as? Float , let lookDownRight = blendShape[.eyeLookDownRight] as? Float , let leftBlink = blendShape[.eyeBlinkLeft] as? Double , let rightBlink = blendShape[.eyeBlinkRight] as? Double else {return }
        var viewLocation = wkWebview.scrollView.contentOffset.y
       print(rightBlink)
        if lookupScrollLeft >= 0.010 {
            viewLocation -= CGFloat(lookupScrollLeft)
            wkWebview.scrollView.contentOffset = CGPoint(x: 0, y: viewLocation)
        } else if lookDownRight >= 0.010 {
            viewLocation += CGFloat(lookDownRight)
            wkWebview.scrollView.contentOffset = CGPoint(x: 0, y: Int(lookDownRight + Float(viewLocation)))
        }
        if leftBlink >= 0.010 {
            wkWebview.goBack()
        } else if rightBlink >= 0.010 {
            wkWebview.goForward()
        } 
    }
}
