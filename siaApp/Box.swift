//
//  Box.swift
//  siaApp
//
//  Created by Amanda Ng on 27/10/17.
//  Copyright © 2017 Amanda Ng. All rights reserved.
//

import SceneKit

class Box: SCNNode {
    init(position: SCNVector3,width: CGFloat,
        height: CGFloat,
        length: CGFloat,
        chamferRadius: CGFloat) {
        super.init()
        
        let box = SCNBox(width: width,height: height,length: length,chamferRadius: 0);
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        material.lightingModel = .physicallyBased
        box.materials = [material]
        self.geometry = box
        self.position = position
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
