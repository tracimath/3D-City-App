//
//  DataModeView.swift
//  DemoTester
//
//  Created by Traci Mathieu on 7/4/18.
//  Copyright © 2018 Traci Mathieu. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

protocol DataDelegate {
    func tapButton(_ sender: UIButton)
}

class DataModeView: UIView {
    
    let exitMode = UIButton()
    let dataA = UIButton()
    let dataB = UIButton()
    let humButton = UIButton()
    let tempButton = UIButton()
    let co2Button = UIButton()
    let noData = UIButton()
    
    var delegate: DataDelegate!
    
    var buildingMode = "None"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setUpButtons() {
        
        dataA.setTitle("Data A", for: .normal)
        dataA.addTarget(self, action: #selector(self.buttonPress(_:)), for: .touchUpInside)
        dataA.showsTouchWhenHighlighted = true
        
        dataB.setTitle("Data B", for: .normal)
        dataB.addTarget(self, action: #selector(self.buttonPress(_:)), for: .touchUpInside)
        dataB.showsTouchWhenHighlighted = true
        
        tempButton.setTitle("Temp", for: .normal)
        tempButton.addTarget(self, action: #selector(self.buttonPress(_:)), for: .touchUpInside)
        tempButton.showsTouchWhenHighlighted = true
        
        humButton.setTitle("Hum", for: .normal)
        humButton.addTarget(self, action: #selector(self.buttonPress(_:)), for: .touchUpInside)
        humButton.showsTouchWhenHighlighted = true
        
        co2Button.setTitle("CO2", for: .normal)
        co2Button.addTarget(self, action: #selector(self.buttonPress(_:)), for: .touchUpInside)
        co2Button.showsTouchWhenHighlighted = true
        
        noData.setTitle("None", for: .normal)
        noData.addTarget(self, action: #selector(self.buttonPress(_:)), for: .touchUpInside)
        noData.showsTouchWhenHighlighted = true
        
        exitMode.setTitle("Exit", for: .normal)
        exitMode.addTarget(self, action: #selector(self.buttonPress(_:)), for: .touchUpInside)
        exitMode.showsTouchWhenHighlighted = true
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        // stackView.addArrangedSubview(dataA)
        // stackView.addArrangedSubview(dataB)
        stackView.addArrangedSubview(tempButton)
        stackView.addArrangedSubview(humButton)
        stackView.addArrangedSubview(co2Button)
        stackView.addArrangedSubview(noData)
        stackView.addArrangedSubview(exitMode)
        stackView.distribution = .fillEqually
        stackView.spacing = 5
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
        
        // add constraints for the horizontal stack view
        self.addConstraint(NSLayoutConstraint(item: stackView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -20))
        self.addConstraint(NSLayoutConstraint(item: stackView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 20))
        self.addConstraint(NSLayoutConstraint(item: stackView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -15))
        
    }
    
    @objc func buttonPress(_ sender: UIButton) {
        delegate.tapButton(sender)
    }
    
}
