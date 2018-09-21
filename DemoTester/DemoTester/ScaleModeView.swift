//
//  ScaleModeView.swift
//  DemoTester
//
//  Created by Traci Mathieu on 7/4/18.
//  Copyright © 2018 Traci Mathieu. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

protocol ScaleDelegate {
    func tapButton(_ sender: UIButton)
}

class ScaleModeView: UIView {
    
    var delegate: ScaleDelegate!
    
    // buttons for the scale
    let smallScale = UIButton() // normal
    let mediumScale = UIButton() // 1:2
    let largeScale = UIButton() // 1:1
    let exitMode = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // set up the scale buttons
    func setUpButtons() {
        
        smallScale.setTitle("1:10⁵", for: .normal)
        mediumScale.setTitle("1:10⁴", for: .normal)
        largeScale.setTitle("1:10²", for: .normal)
        exitMode.setTitle("Exit", for: .normal)
        
        smallScale.showsTouchWhenHighlighted = true
        mediumScale.showsTouchWhenHighlighted = true
        largeScale.showsTouchWhenHighlighted = true
        exitMode.showsTouchWhenHighlighted = true
        
        smallScale.addTarget(self, action: #selector(self.buttonPress(_:)), for: .touchUpInside)
        mediumScale.addTarget(self, action: #selector(self.buttonPress(_:)), for: .touchUpInside)
        largeScale.addTarget(self, action: #selector(self.buttonPress(_:)), for: .touchUpInside)
        exitMode.addTarget(self, action: #selector(self.buttonPress(_:)), for: .touchUpInside)
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.addArrangedSubview(smallScale)
        stackView.addArrangedSubview(mediumScale)
        stackView.addArrangedSubview(largeScale)
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

