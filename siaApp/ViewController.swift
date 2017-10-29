//
//  init_arkit.swift
//  siaApp
//
//  Created by Amanda Ng on 26/10/17.
//  Copyright © 2017 Amanda Ng. All rights reserved.
//


import UIKit
import ARKit
import SceneKit

class ViewController: UIViewController, ARSCNViewDelegate {
    var nodes: [SphereNode] = []
    var dist : [CGFloat] = []
    var coor : [SCNVector3] = []
   
    
    
    lazy var sceneView: ARSCNView = {
        let view = ARSCNView(frame: CGRect.zero)
        view.delegate = self
        view.autoenablesDefaultLighting = true
        view.antialiasingMode = SCNAntialiasingMode.multisampling4X
        return view
    }()
    
    lazy var infoLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
        label.textAlignment = .center
        label.backgroundColor = .white
        return label
    }()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(sceneView)
        view.addSubview(infoLabel)
        let button = UIButton(frame :CGRect(x: 100, y: 100, width: 100, height: 50))
        
        button.addTarget(self, action: #selector(reset), for: .touchUpInside)
        button.setTitle("Reset", for: [])
        self.view.addSubview(button)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapRecognizer.numberOfTapsRequired = 1
        sceneView.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneView.frame = view.bounds
        infoLabel.frame = CGRect(x: 0, y: 16, width: view.bounds.width, height: 64)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        
        configuration.planeDetection = .horizontal
        
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
    }
    
    // MARK: ARSCNViewDelegate
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        var status = "Loading..."
        switch camera.trackingState {
        case ARCamera.TrackingState.notAvailable:
            status = "Not available"
        case ARCamera.TrackingState.limited(_):
            status = "Analyzing..."
        case ARCamera.TrackingState.normal:
            status = "Ready"
        }
        infoLabel.text = status
        
    }
    
   
    
    // MARK: Gesture handlers
    @objc func handleTap(sender: UITapGestureRecognizer) {
        
        let tapLocation = sender.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .featurePoint)
        if let result = hitTestResults.first {
            let position = SCNVector3.positionFrom(matrix: result.worldTransform)
            let sphere = SphereNode(position: position)
            sceneView.scene.rootNode.addChildNode(sphere)
            let lastNode = nodes.last
            nodes.append(sphere)
            if lastNode != nil {
                let distance = lastNode!.position.distance(to: sphere.position)
                infoLabel.text = String(format: "Distance: %.2f meters", distance)
                dist.append(distance)
                if nodes.count == 3{
                    coor.append(SCNVector3Make((nodes[1].position.x + nodes[2].position.x)/2 , nodes[2].position.y, nodes[2].position.z))
                }
                
                let line = SCNGeometry.lineFrom(vector: (lastNode?.position)!, toVector: sphere.position)
                let lineNode = SCNNode(geometry: line)
                lineNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                sceneView.scene.rootNode.addChildNode(lineNode)
            }
        }
        
        if dist.count == 3{
            infoLabel.text = String(format:"Width:%.2f meters | Height:%.2f meters | Length: %.2f", dist[0],dist[2],dist[1])
            let box = SCNBox(width: dist[0], height: dist[2], length: dist[1], chamferRadius: 0)
            let nodebox = SCNNode(geometry: box)
            nodebox.geometry?.firstMaterial?.diffuse.contents = UIColor.green
            sceneView.scene.rootNode.addChildNode(nodebox)
            dist.removeAll()
            nodes.removeAll()
        }
        
    }
    
    @objc func reset(sender: UIButton!){
        nodes.removeAll()
        dist.removeAll()
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.pause()
        sceneView.scene.rootNode.enumerateChildNodes{(node,stop) in node.removeFromParentNode()}
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
    }
    
}

extension SCNVector3 {
    func distance(to destination: SCNVector3) -> CGFloat {
        let dx = destination.x - x
        let dy = destination.y - y
        let dz = destination.z - z
        return CGFloat(sqrt(dx*dx + dy*dy + dz*dz))
    }
    
 
    
    static func positionFrom(matrix: matrix_float4x4) -> SCNVector3 {
        let column = matrix.columns.3
        return SCNVector3(column.x, column.y, column.z)
    }
}

extension SCNGeometry{
    class func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
        let indices: [Int32] = [0, 1]
        
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        
        return SCNGeometry(sources: [source], elements: [element])
        
    }
}
