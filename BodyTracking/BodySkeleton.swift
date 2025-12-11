//
//  BodySkeleton.swift
//  BodyTracking
//
//  Created by sofiadinizms on 22/03/23.
//

import Foundation
import ARKit
import RealityKit

class bodySkeleton: Entity{
    
    var joints: [String:Entity] = [:]
    var bones: [String:Entity] = [:]
    
    init(for bodyAnchor: ARBodyAnchor){
        super.init()
        
        for jointName in ARSkeletonDefinition.defaultBody3D.jointNames{
            var jointRadius: Float = 0.05
            var jointColor: UIColor = .green
            
            switch jointName{
            case "neck_1_joint","neck_2_joint", "neck_3_joint", "neck_4_joint", "head_joint", "left_soulder_1_joint", "right_shoulder_1_joint":
                jointRadius *= 0.5
            //pulei um case que era de joints dos olhos pq acho que a gente não vai usar
            case _ where jointName.hasPrefix("spine_"):
                jointRadius *= 0.5
            case "left_hand_joint", "right_hand_joint":
                jointRadius *= 1
                jointColor = .green
            case _ where jointName.hasPrefix("left_hand") || jointName.hasPrefix("right_hand"):
                jointRadius *= 0.25
                jointColor = .yellow
            case _ where jointName.hasPrefix("left_toes") || jointName.hasPrefix("right_toes"):
                jointRadius *= 0.5
                jointColor = .yellow
            default:
                jointRadius = 0.05
                jointColor = .green
            }
            
            let jointEntity = createJoint(radius: jointRadius, color: jointColor)
            joints[jointName] = jointEntity
            self.addChild(jointEntity)
        }
        
        for bone in Bones.allCases{
            
            guard let skeletonBone = createSkeletonBone(bone: bone, bodyAnchor: bodyAnchor)
            else {continue}
            
            // criar uma entitdade para o osso, adicionar ao dicionário de ossos, e adicionar a entidade pai (o esqueleto)
            
            let boneEntity = createBoneEntity(for: skeletonBone)
            bones[bone.name] = boneEntity
            self.addChild(boneEntity)
        }
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    func update(with bodyAnchor: ARBodyAnchor){
        let rootPosition = simd_make_float3(bodyAnchor.transform.columns.3)
        
        for jointName in ARSkeletonDefinition.defaultBody3D.jointNames{
            if let jointEntity = joints[jointName],
               let jointEntityTransform = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: jointName)) {
                
                let jointEntityOffsetFromRoot = simd_make_float3(jointEntityTransform.columns.3)
                jointEntity.position = jointEntityOffsetFromRoot + rootPosition
                jointEntity.orientation = Transform(matrix: jointEntityTransform).rotation
            }
        
        for bone in Bones.allCases{
            let boneName = bone.name

            guard let entity = bones[boneName],
                let skeletonBone = createSkeletonBone(bone: bone, bodyAnchor: bodyAnchor)
            else {continue}

            entity.position = skeletonBone.centerPosition
            entity.look(at: skeletonBone.toJoint.position, from: skeletonBone.centerPosition, relativeTo: nil) //definir a orientação do osso
            }
        }
    }
    
    private func createJoint(radius: Float, color: UIColor = .white) -> Entity{
        let mesh = MeshResource.generateSphere(radius:radius)
        let material = SimpleMaterial(color: color, roughness: 0.8, isMetallic: false)
        let entity = ModelEntity(mesh:mesh, materials: [material])
        
        return entity
    }
    
    
    private func createSkeletonBone(bone: Bones, bodyAnchor: ARBodyAnchor) -> SkeletonBone? {
        guard let fromJointEntityTransform = bodyAnchor.skeleton.modelTransform(for: ARSkeleton
        .JointName(rawValue: bone.jointFromName)),
        let toJointEntityTransform = bodyAnchor.skeleton.modelTransform(for: ARSkeleton
        .JointName(rawValue: bone.jointToName))
        
        else {return nil}

        let rootPosition = simd_make_float3(bodyAnchor.transform.columns.3)
        
        let jointFromEntityOffsetFromRoot = simd_make_float3(fromJointEntityTransform.columns.3)//relative to root/hipjoint

        let jointFromEntityPosition = jointFromEntityOffsetFromRoot + rootPosition //relative to world reference frame
        
        let jointToEntityOffsetFromRoot = simd_make_float3(toJointEntityTransform.columns.3) //relative to hipjoint
        
        let jointToEntityPosition = jointToEntityOffsetFromRoot + rootPosition //relative to world reference frame
        
        let fromJoint = SkeletonJoint(name: bone.jointFromName, position: jointFromEntityPosition)
        let toJoint = SkeletonJoint(name: bone.jointToName, position: jointToEntityPosition)
        return SkeletonBone(fromJoint: fromJoint, toJoint: toJoint)
    }
    
    private func createBoneEntity(for skeletonBone: SkeletonBone, diameter: Float = 0.04, color: UIColor = .white) -> Entity{
        let mesh = MeshResource.generateBox(size: [diameter, diameter, skeletonBone.length], cornerRadius: diameter/2) // cria um cilindro que vai representar os ossos
        let material = SimpleMaterial(color: color, roughness: 0.5, isMetallic: true)
        let entity = ModelEntity(mesh:mesh, materials: [material]) // aqui cria de fato o osso com os parametros passados acima
        
        return entity
    }

}
