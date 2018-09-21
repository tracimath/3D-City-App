//
//  UndoActionHelper.swift
//  
//
//  Created by Traci Mathieu on 7/9/18.
//

import Foundation
import SceneKit

class UndoActionHelper {
    
    // array of unchanged nodes
    var originalNodes: [SCNNode?] = []
    
    // array of changed nodes
    var changedNodes: [SCNNode] = []
    
    func addAction(originalNode: SCNNode?, changedNode: SCNNode) {
        originalNodes.append(originalNode)
        changedNodes.append(changedNode)
    }
    
    func undoAction() {
        
    }
    
    func redoAction() {
        
    }
    
    func reset() {
        originalNodes.removeAll()
        changedNodes.removeAll()
    }
    
    func resetCityModel() -> ([SCNNode?], [SCNNode]) {
        return (originalNodes, changedNodes)
    }
}
