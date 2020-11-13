//
//  ViewController.swift
//  Argonautica-Sait
//
//  Created by Giorgi Butbaia on 11/13/20.
//  Copyright © 2020 Argonautica. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: ARStereoViewController {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var sceneViewLeft: ARSCNView!
    @IBOutlet weak var sceneViewRight: ARSCNView!
    @IBOutlet weak var imageViewLeft: UIImageView!
    @IBOutlet weak var imageViewRight: UIImageView!

    // Object onto which the user gases onto
    private var targetObject: SCNNode = SCNNode()

    let backgroundCOlor = UIColor.black;

    override func viewDidLoad() {
        // Bind view
        bindView(
            sceneView, sceneViewLeft, sceneViewRight,
            imageViewLeft, imageViewRight)

        super.viewDidLoad()
        sceneView.delegate = self

        sceneView.scene.rootNode.addChildNode(targetObject)
        addFloor(width: 10.0, length: 10.0)
        targetObject.geometry = SCNSphere(radius: 0.1)
    }
    
    private func addFloor(width: CGFloat, length: CGFloat) {
        // Define floor
        let floor = SCNFloor()
        floor.width = width
        floor.length = length
        floor.reflectivity = 0.0

        let floorNode = SCNNode(geometry: floor)
        floorNode.position = SCNVector3Make(0, -0.1, 0)
        self.sceneView.scene.rootNode.addChildNode(floorNode)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    override func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        super.renderer(renderer, updateAtTime: time)
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
