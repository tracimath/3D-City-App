//
//  BuildingModeView.swift
//  DemoTester
//
//  Created by Traci Mathieu on 7/4/18.
//  Copyright © 2018 Traci Mathieu. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

protocol BuildingDelegate {
    func tapButton(_ sender: UIButton)
}

class BuildingModeView: UIView {
    
    let colorBuilding = UIButton()
    let scaleBuilding = UIButton()
    let exitMode = UIButton()
    
    var buildingMode = "None"
    var delegate: BuildingDelegate!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func changeBuilding(node: SCNNode) -> SCNNode {
        if buildingMode == "Color" {
            return changeColor(node: node)
        }
        else if buildingMode == "Scale" {
            return changeScale(node: node)
        }
        else {
            return node
        }
    }
    
    func changeColor(node: SCNNode) -> SCNNode {
        print("change color")
        let buildingMaterial = SCNMaterial()
        buildingMaterial.diffuse.contents = UIColor(red: (34/255.0), green: (139/255.0), blue: (34/255.0), alpha: 1.0)
        node.geometry?.materials = [buildingMaterial]
        return node
    }
    
    func changeScale(node: SCNNode) -> SCNNode {
        print("change scale")
        node.scale.z = 5
        return node
    }
    
    func setUpButtons() {
        
        colorBuilding.setTitle("Color", for: .normal)
        colorBuilding.addTarget(self, action: #selector(self.tapButton(_:)), for: .touchUpInside)
        colorBuilding.showsTouchWhenHighlighted = true
        
        scaleBuilding.setTitle("Scale", for: .normal)
        scaleBuilding.addTarget(self, action: #selector(self.tapButton(_:)), for: .touchUpInside)
        scaleBuilding.showsTouchWhenHighlighted = true
        
        exitMode.setTitle("Exit", for: .normal)
        exitMode.addTarget(self, action: #selector(self.buttonPress(_:)), for: .touchUpInside)
        exitMode.showsTouchWhenHighlighted = true
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.addArrangedSubview(colorBuilding)
        stackView.addArrangedSubview(scaleBuilding)
        stackView.addArrangedSubview(exitMode)
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
        
        // add constraints for the horizontal stack view
        self.addConstraint(NSLayoutConstraint(item: stackView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -20))
        self.addConstraint(NSLayoutConstraint(item: stackView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 20))
        self.addConstraint(NSLayoutConstraint(item: stackView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -15))
    }
    
    @objc func tapButton(_ sender: UIButton) {

        if sender.currentTitle == "Color" {
            buildingMode = "Color"
            print("\(buildingMode)")
        }
        else if sender.currentTitle == "Scale" {
            buildingMode = "Scale"
            print("\(buildingMode)")
        }
        
        if buildingMode == "Color" {
            colorBuilding.setTitleColor(UIColor.black, for: .normal)
            scaleBuilding.setTitleColor(UIColor.white, for: .normal)
        }
        else if buildingMode == "Scale" {
            colorBuilding.setTitleColor(UIColor.white, for: .normal)
            scaleBuilding.setTitleColor(UIColor.black, for: .normal)
        }
        else {
            colorBuilding.setTitleColor(UIColor.white, for: .normal)
            scaleBuilding.setTitleColor(UIColor.white, for: .normal)
        }
    }
    
    @objc func buttonPress(_ sender: UIButton) {
        
        delegate.tapButton(sender)
    }
}
