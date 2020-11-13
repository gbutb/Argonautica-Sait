//
//  ARStereoViewController.swift
//  Argonautica-Sait
//
//  Created by Giorgi Butbaia on 11/13/20.
//  Copyright © 2020 Argonautica. All rights reserved.
//

import Foundation
import ARKit

class ARStereoViewController: UIViewController, ARSCNViewDelegate {
    private var sceneView_v: ARSCNView!
    private var sceneViewLeft_v: ARSCNView!
    private var sceneViewRight_v: ARSCNView!
    
    private var imageViewLeft_v: UIImageView!
    private var imageViewRight_v: UIImageView!

    // Camera configuration
    private let eyeCamera = SCNCamera()
    private let eyeFOV = 60;
    private var cameraImageScale = 3.478;
    private let interPupilaryDistance : Float = 0.066

    override func viewDidLoad() {
        super.viewDidLoad()

        // Prevent lock
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Prevent dimming
        let currentBrightness = UIScreen.main.brightness
        UIScreen.main.brightness = currentBrightness

        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        sceneView_v.scene = scene
        
        // Create light
        let directionalNode = SCNNode()
        directionalNode.light = SCNLight()
        directionalNode.light?.type = SCNLight.LightType.directional
        directionalNode.light?.color = UIColor.white
        directionalNode.light?.intensity = 2000

        directionalNode.light?.castsShadow = true

        sceneView_v.pointOfView?.addChildNode(directionalNode)

        // Clear scene
        // TODO: Check this
        // sceneView_v.scene.background.contents = UIColor.clear
        sceneView_v.isHidden = true

        // Configure left scene
        sceneViewLeft_v.scene = scene
        sceneViewLeft_v.isPlaying = true
        imageViewLeft_v.clipsToBounds = true
        imageViewLeft_v.contentMode = UIView.ContentMode.center

        // Configure right scene
        sceneViewRight_v.scene = scene
        sceneViewRight_v.isPlaying = true
        imageViewRight_v.clipsToBounds = true
        imageViewRight_v.contentMode = UIView.ContentMode.center

        // Configure camera
        if #available(iOS 11.3, *) {
            print("iOS 11.3 or later")
            cameraImageScale = cameraImageScale * 1080.0 / 720.0
        } else {
            print("earlier than iOS 11.3")
        }
        eyeCamera.zNear = 0.001
        eyeCamera.fieldOfView = CGFloat(eyeFOV)
    }

    func bindView(
            _ sceneView: ARSCNView, _ sceneViewLeft: ARSCNView, _ sceneViewRight: ARSCNView,
            _ imageViewLeft: UIImageView, _ imageViewRight: UIImageView) {
        sceneView_v = sceneView
        sceneViewLeft_v = sceneViewLeft
        sceneViewRight_v = sceneViewRight

        imageViewLeft_v = imageViewLeft
        imageViewRight_v = imageViewRight
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            if !self.update() {
                print("Error")
            }
        }
    }

    /**
     * Applies transformation from one POV to another.
     */
    private func transform(_ orientation: GLKQuaternion, _ eyePos: GLKVector3, _ magnitude: Float) -> SCNVector3 {
        let rotatedEyePos = GLKQuaternionRotateVector3(orientation, eyePos)

        return SCNVector3Make(
            rotatedEyePos.x * magnitude,
            rotatedEyePos.y * magnitude,
            rotatedEyePos.z * magnitude)
    }
    
    private func update() -> Bool {
        guard let scenePOV = sceneView_v.pointOfView else { return false }

        let pointOfView = SCNNode()
        pointOfView.transform = scenePOV.transform
        pointOfView.scale = scenePOV.scale
        pointOfView.camera = eyeCamera
        
        guard let sceneViewMain = sceneViewRight_v else { return false }
        guard let sceneViewSecond = sceneViewLeft_v else { return false }

        // Set point of view of the main scene
        sceneViewMain.pointOfView = pointOfView

        // Define the secondary point of view
        guard let pointOfViewSecond = sceneViewMain.pointOfView?.clone() else { return false }
        let orientation = pointOfViewSecond.orientation
        let orientationGLK = GLKQuaternionMake(orientation.x, orientation.y, orientation.z, orientation.w)
        let secondEyePos = GLKVector3Make(-1.0, 0.0, 0.0)
        let transformVector = transform(
            orientationGLK, secondEyePos, interPupilaryDistance)

        pointOfViewSecond.localTranslate(by: transformVector)
        sceneViewSecond.pointOfView = pointOfViewSecond

        return updateImages()
    }
    
    private func updateImages() -> Bool {
        sceneView_v.scene.background.contents = UIColor.clear
        
        guard let pixelBuffer = sceneView_v.session.currentFrame?.capturedImage else { return false }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return false }
        
        let scaleCustom = CGFloat(cameraImageScale)
        let imageOrientation = (UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.landscapeLeft) ?
            UIImage.Orientation.down : UIImage.Orientation.up
        
        let uiImage = UIImage(cgImage: cgImage, scale: scaleCustom, orientation: imageOrientation)
        self.imageViewLeft_v.image = uiImage
        self.imageViewRight_v.image = uiImage

        return true
    }
}
