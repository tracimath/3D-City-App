//
//  AddObjectHelper.swift
//  
//
//  Created by Traci Mathieu on 7/3/18.
//

import Foundation
import UIKit
import ARKit

// set up button to exit mode

// set up the buttons for each of the objects that you can add to the view
// add buttons
// when the user clicks on the button, it's adding that object to the view
class AddObjectHelper {
    
    init(sceneView: ARSCNView) {
        self.sceneView = sceneView
    }
    
    // set up button for each object
    let treeButton = UIButton()
    var sceneView: ARSCNView
    
    func setUpButtons() {
        treeButton.setTitle("Tree", for: .normal)
        sceneView.addSubview(treeButton)
        treeButton.frame = CGRect.init(x: 10.0, y:100.0, width: 60.0, height: 60.0)
        treeButton.addTarget(sceneView, action: #selector(ViewController.tapButton(_:)), for: .touchUpInside)
    }
    
    func addTree() {
        print("add tree")
    }
    
    @objc func tapButton(_ sender: UIButton) {
        if sender == treeButton {
            addTree()
        }
    }
}
