//
//  SkeletonBone.swift
//  BodyTracking
//
//  Created by sofiadinizms on 22/03/23.
//

import Foundation
import RealityKit

struct SkeletonBone{
    var fromJoint: SkeletonJoint
    var toJoint: SkeletonJoint
    
    var centerPosition: SIMD3<Float>{
        [(fromJoint.position.x + toJoint.position.x)/2, (fromJoint.position.y + toJoint.position.y)/2, (fromJoint.position.z + toJoint.position.z)/2]
    } // calcula o ponto intermediário entre as articulações
    
    var length: Float {
        simd_distance(fromJoint.position, toJoint.position)
    }
}
