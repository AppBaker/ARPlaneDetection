//
//  ViewController.swift
//  ARPlane StarryWings
//
//  Created by Ivan Nikitin on 26/03/2019.
//  Copyright © 2019 Ivan Nikitin. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
    
    var carNode = [SCNNode]()

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.debugOptions = [.showFeaturePoints]
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }


}
// MARK: - ... ARSCNViewDelegate

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor else { return }
        node.addChildNode(createFloor(planeAnchor: anchor))
        
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor else { return }
        guard let planeNode = node.childNodes.first else { return }
        guard let plane = planeNode.geometry as? SCNPlane else { return }
        guard planeNode.name == "Plane" else { return }
         
        planeNode.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
        let extent = anchor.extent
        plane.width = CGFloat(extent.x)
        plane.height = CGFloat(extent.z)
        
    }
}

//MARK: - ... Custom Methods
extension ViewController {
    
    func createFloor(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let node = SCNNode()
        let mainNode = SCNNode()
        let extent = planeAnchor.extent
        
        let plane = SCNPlane(width: CGFloat(extent.x), height: CGFloat(extent.z))
        plane.materials.first?.diffuse.contents = UIColor.blue
        node.geometry = plane
        node.name = "Plane"
        node.eulerAngles.x = -Float.pi/2
        node.opacity = 0.25
        
        if let car = createCar(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z, angel: 0) {
            carNode += [car]
            mainNode.addChildNode(car)
        }
        
        mainNode.addChildNode(node)
        
        return mainNode
    }
    
    func createCar(x: Float = 0, y: Float = 0, z: Float = 0, angel: Float = 0) -> SCNNode? {
        guard let scene = SCNScene(named: "art.scnassets/Muscle_Coupe.scn") else { return nil }
        
        let node = scene.rootNode
        node.position = SCNVector3(x, y, z)
        node.eulerAngles.x = angel
        
        return node
    }
    
    @IBAction func turnButtonTapped(sender: UIBarButtonItem) {
        
        carNode.forEach { (car) in
            car.runAction(SCNAction.rotateBy(
                x: 0,
                y: .pi * 2,
                z: 0,
                duration: 1))
        }
    }
}
