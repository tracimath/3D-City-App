//
//  ObjectModeView.swift
//  DemoTester
//
//  Created by Traci Mathieu on 7/3/18.
//  Copyright © 2018 Traci Mathieu. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

protocol ObjectDelegate {
    func tapButton(_ sender: UIButton)
}

class ObjectModeView: UIView {
    
    var delegate: ObjectDelegate!
    let treeButton = UIButton()
    let bushButton = UIButton()
    let exitMode = UIButton()
    
    var objectMode = "None"
    let bushNode = SCNNode()
    let treeNode = SCNNode()
    let boletusNode = SCNNode()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setUpButtons() {
        
        treeButton.showsTouchWhenHighlighted = true
        bushButton.showsTouchWhenHighlighted = true
        exitMode.showsTouchWhenHighlighted = true
        
        treeButton.setTitle("Tree", for: .normal)
        treeButton.addTarget(self, action: #selector(self.tapButton(_:)), for: .touchUpInside)
        
        bushButton.setTitle("Bush", for: .normal)
        bushButton.addTarget(self, action: #selector(self.tapButton(_:)), for: .touchUpInside)
    
        exitMode.setTitle("Exit", for: .normal)
        exitMode.addTarget(self, action: #selector(self.buttonPress(_:)), for: .touchUpInside)
            
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.addArrangedSubview(treeButton)
        stackView.addArrangedSubview(bushButton)
        stackView.addArrangedSubview(exitMode)
        stackView.spacing = 5
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
        
        // add constraints for the horizontal stack view
        self.addConstraint(NSLayoutConstraint(item: stackView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -20))
        self.addConstraint(NSLayoutConstraint(item: stackView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 20))
        self.addConstraint(NSLayoutConstraint(item: stackView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -15))
        
        setUpObjects()

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addObject(position: SCNVector3) -> SCNNode {
        if objectMode == "Tree" {
            return addTree(position: position)
        }
        else if objectMode == "Bush" {
            return addBush(position: position)
        }
        else {
            // boletus is default object
            return addBoletus(position: position)
        }
    }
    
    func setUpObjects() {
        let sceneBush = SCNScene(named: "bush.dae")
        let bushArray = sceneBush?.rootNode.childNodes
        
        for childNode in bushArray! {
            if (childNode.geometry != nil) {
                bushNode.addChildNode(childNode)
            }
        }
        
        bushNode.name = "Bush"
        bushNode.scale = SCNVector3(10000, 10000, 10000)
        
        let sceneTree = SCNScene(named: "tree.dae")
        let treeArray = sceneTree?.rootNode.childNodes
        
        for childNode in treeArray! {
            if (childNode.geometry != nil) {
                treeNode.addChildNode(childNode)
            }
        }
        treeNode.name = "Tree"
        treeNode.scale = SCNVector3(10000, 10000, 10000)
        
        let sceneBoletus = SCNScene(named: "boletus.dae")
        let boletusArray = sceneBoletus?.rootNode.childNodes
        
        for childNode in boletusArray! {
            if (childNode.geometry != nil) {
                boletusNode.addChildNode(childNode)
            }
        }
    
        boletusNode.name = "Boletus"
        boletusNode.scale = SCNVector3(100, 100, 100)
        
    }
    
    func addBush(position: SCNVector3) -> SCNNode {
        print("add bush")
        
        bushNode.position = position
        return bushNode.clone()
    }
    
    func addTree(position: SCNVector3) -> SCNNode {
        print("add tree")
        treeNode.position = position
        return treeNode.clone()
    }
    
    func addBoletus(position: SCNVector3) -> SCNNode {
        print("add boletus")
        boletusNode.position = position
        return boletusNode.clone()
    }
    
    @objc func tapButton(_ sender: UIButton) {
        if sender.currentTitle == "Tree" {
            objectMode = "Tree"
            print("\(objectMode)")
        }
        else if sender.currentTitle == "Bush" {
            objectMode = "Bush"
        }
        
        if objectMode == "Tree" {
            treeButton.setTitleColor(UIColor.black, for: .normal)
            bushButton.setTitleColor(UIColor.white, for: .normal)
        }
        else if objectMode == "Bush" {
            bushButton.setTitleColor(UIColor.black, for: .normal)
            treeButton.setTitleColor(UIColor.white, for: .normal)
        }
        else {
            treeButton.setTitleColor(UIColor.white, for: .normal)
            bushButton.setTitleColor(UIColor.white, for: .normal)
        }
    }
    
    @objc func buttonPress(_ sender: UIButton) {
        delegate.tapButton(sender)
    }
}
