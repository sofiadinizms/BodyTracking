//
//  ARViewContainer.swift
//  BodyTracking
//
//  Created by sofiadinizms on 17/03/23.
//

import ARKit
import RealityKit
import SwiftUI

private var BodySkeleton: bodySkeleton?
private let bodySkeletonAnchor = AnchorEntity()

struct ARViewContainer: UIViewRepresentable{
    typealias UIViewType = ARView
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: true)
        
                arView.setupForBodyTracking()
                arView.scene.addAnchor(bodySkeletonAnchor)

        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
    
}

extension ARView: ARSessionDelegate {
    func setupForBodyTracking() {
        let configuration = ARBodyTrackingConfiguration()
        self.session.run(configuration)
        
        self.session.delegate = self
    }
    
    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]){
        for anchor in anchors {
            if let bodyAnchor = anchor as? ARBodyAnchor{
                if let skeleton = BodySkeleton {
                    //body skeleton already exists, update all joints and bones
                    skeleton.update(with: bodyAnchor)
                }    else {
                    // bodyskeleton doesnt exist yet. this means a body has been detected for the first time
                    // create bodyskeleton entity and add it to the bodyskeletonanchor
                    BodySkeleton = bodySkeleton(for: bodyAnchor)
                    bodySkeletonAnchor.addChild(BodySkeleton!)
                }
            }
        }

    }

}
