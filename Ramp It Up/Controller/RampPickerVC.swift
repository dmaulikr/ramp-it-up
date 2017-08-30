//
//  RampPickerVC.swift
//  Ramp It Up
//
//  Created by Roger on 29/08/17.
//  Copyright © 2017 Decodely. All rights reserved.
//

import UIKit
import SceneKit

class RampPickerVC: UIViewController {

	var sceneView: SCNView!
    var size: CGSize!
	weak var rampPlacerVC: RampPlacerVC!
    
    init(bySize size: CGSize){
        super.init(nibName: nil, bundle: nil)
        self.size = size
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.frame = CGRect(origin: CGPoint.zero, size: size)
        sceneView = SCNView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        view.insertSubview(sceneView, at: 0)

		preferredContentSize = size

		view.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
		view.layer.borderWidth = 3.0

		let scene = SCNScene(named:"art.scnassets/ramps.scn")!
        sceneView.scene = scene

        let camera = SCNCamera()
        camera.usesOrthographicProjection = true
        scene.rootNode.camera = camera

		let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(forGesture:)))
        sceneView.addGestureRecognizer(tap)

		let pipe = Ramp.getPipe()
		Ramp.startRotation(forNode: pipe)
		scene.rootNode.addChildNode(pipe)

		let pyramid = Ramp.getPyramid()
		Ramp.startRotation(forNode: pyramid)
		scene.rootNode.addChildNode(pyramid)

		let quarter = Ramp.getQuarter()
		Ramp.startRotation(forNode: quarter)
		scene.rootNode.addChildNode(quarter)
    }

	@objc func handleTap(forGesture gestureRecognizer: UIGestureRecognizer){
		let p = gestureRecognizer.location(in: sceneView)
		let hitResults = sceneView.hitTest(p, options: [:])

		if hitResults.count > 0 {
			let node = hitResults[0].node
			rampPlacerVC.onRampSeletec(node.name!)
			dismiss(animated: true, completion: nil)
		}
	}
}
