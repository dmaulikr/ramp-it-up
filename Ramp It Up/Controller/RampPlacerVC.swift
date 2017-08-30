//
//  ViewController.swift
//  Ramp It Up
//
//  Created by Roger on 29/08/17.
//  Copyright © 2017 Decodely. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class RampPlacerVC: UIViewController, ARSCNViewDelegate, UIPopoverPresentationControllerDelegate {

	var selectedRampName: String?
	var selectedRamp: SCNNode?

	@IBOutlet var sceneView: ARSCNView!
	@IBOutlet weak var buttonsStackView: UIStackView!
	@IBOutlet weak var rotateBtn: UIButton!
	@IBOutlet weak var upBtn: UIButton!
	@IBOutlet weak var downBtn: UIButton!
	
	override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.delegate = self
        sceneView.showsStatistics = true

		let scene = SCNScene(named: "art.scnassets/main.scn")
		sceneView.autoenablesDefaultLighting = true
        sceneView.scene = scene!

		let gesture1 = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(gesture:)))
		let gesture2 = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(gesture:)))
		let gesture3 = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(gesture:)))

		gesture1.minimumPressDuration = 0.1
		gesture2.minimumPressDuration = 0.1
		gesture3.minimumPressDuration = 0.1

		rotateBtn.addGestureRecognizer(gesture1)
		upBtn.addGestureRecognizer(gesture2)
		downBtn.addGestureRecognizer(gesture3)
    
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

    func session(_ session: ARSession, didFailWithError error: Error) {}
    
    func sessionWasInterrupted(_ session: ARSession) {}
    
    func sessionInterruptionEnded(_ session: ARSession) {}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else {return}
		let results = sceneView.hitTest(touch.location(in: sceneView), types: ARHitTestResult.ResultType.featurePoint)
		guard let hitFeatured = results.last else { return }
		let hitTransform = SCNMatrix4(hitFeatured.worldTransform)
		let hitPosition = SCNVector3Make(hitTransform.m41, hitTransform.m42, hitTransform.m43)

		placeRamp(placePosition: hitPosition)
	}

	func placeRamp(placePosition position: SCNVector3){
		if let rampName = selectedRampName {
			buttonsStackView.isHidden = false
			let ramp = Ramp.getRamp(forName: rampName)
			self.selectedRamp = ramp
			ramp.position = position
//			ramp.scale = SCNVector3Make(0.01, 0.01, 0.01)
			ramp.scale = SCNVector3Make(0.001, 0.001, 0.001)
			sceneView.scene.rootNode.addChildNode(ramp)

		}
	}

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    @IBAction func onRampBtnPressed(_ sender: UIButton) {
    	let rampPickerVC = RampPickerVC(bySize: CGSize(width: 250, height: 500))
		rampPickerVC.rampPlacerVC = self
        rampPickerVC.modalPresentationStyle = .popover
        rampPickerVC.popoverPresentationController?.delegate = self
        rampPickerVC.popoverPresentationController?.sourceView = sender
        rampPickerVC.popoverPresentationController?.sourceRect = sender.bounds
        
        present(rampPickerVC, animated: true, completion: nil)
    }

	func onRampSeletec(_ rampName: String){
		selectedRampName = rampName
	}

	@IBAction func onRemoveBtnPressed(_ sender: UIButton) {
		if let ramp = selectedRamp {
			ramp.removeFromParentNode()
			selectedRamp = nil
		}
	}

	@objc func onLongPress(gesture: UILongPressGestureRecognizer){
		if let ramp = selectedRamp {
			if gesture.state == .ended {
				ramp.removeAllActions()
			} else if gesture.state == .began {
				if gesture.view === rotateBtn {
					let rotate = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: (CGFloat(0.08 * Double.pi)) , z: 0, duration: 0.1))
					ramp.runAction(rotate)
				} else if gesture.view === upBtn {
					let move = SCNAction.repeatForever(SCNAction.moveBy(x: 0, y: 0.08, z: 0, duration: 0.1))
					ramp.runAction(move)
				} else if gesture.view === downBtn {
					let move = SCNAction.repeatForever(SCNAction.moveBy(x: 0, y: -0.08, z: 0, duration: 0.1))
					ramp.runAction(move)
				}
			}
		}
	}

}
