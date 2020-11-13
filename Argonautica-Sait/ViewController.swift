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

class ViewController: ARStereoViewController, SpeechControllerDelegate {
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var sceneViewLeft: ARSCNView!
    @IBOutlet weak var sceneViewRight: ARSCNView!
    @IBOutlet weak var imageViewLeft: UIImageView!
    @IBOutlet weak var imageViewRight: UIImageView!

    // Object onto which the user gases onto
    private var targetObject: SCNNode = SCNNode()
    private let speechController = SpeechController()

    let backgroundCOlor = UIColor.black;

    override func viewDidLoad() {
        // Bind view
        bindView(
            sceneView, sceneViewLeft, sceneViewRight,
            imageViewLeft, imageViewRight)

        super.viewDidLoad()
        sceneView.delegate = self
        speechController.delegate = self

        sceneView.scene.rootNode.addChildNode(targetObject)
        addFloor(width: 10.0, length: 10.0)
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
    
    func start() {
        let duration: Double = 5.0
        let actions: [SCNAction] = [
            SCNAction.move(
                to: SCNVector3Make(0, 0, -1),
                duration: duration),
            SCNAction.move(
                to: SCNVector3Make(0, 0, 0),
                duration: duration)]
        let anim = SCNAction.sequence(actions)
        targetObject.runAction(SCNAction.repeatForever(anim))
    }
    
    func stop() {
        targetObject.removeAllActions()
        targetObject.position = SCNVector3Make(0, 0, 0)
    }
    
    func changeGeometry(_ geometryType: GeometryType) {
        switch geometryType {
            case .Sphere:
                targetObject.geometry = SCNSphere(radius: 0.1)
                targetObject.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 0.3, green: 0.5, blue: 0.4, alpha: 1 )
            case .Torus:
                targetObject.geometry = SCNTorus(ringRadius: 0.1, pipeRadius: 0.01)
                targetObject.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 0.3, green: 0.5, blue: 0.4, alpha: 1 )
        }
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
