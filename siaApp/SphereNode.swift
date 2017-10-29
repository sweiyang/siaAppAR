//
//  SphereNode.swift
//  siaApp
//
//  Created by Amanda Ng on 26/10/17.
//  Copyright © 2017 Amanda Ng. All rights reserved.
//

import SceneKit

class SphereNode: SCNNode {
    init(position: SCNVector3) {
        super.init()
        let sphereGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        material.lightingModel = .physicallyBased
        sphereGeometry.materials = [material]
        self.geometry = sphereGeometry
        self.position = position
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
