//
//  PointCloud.cpp
//  DemoTester
//
//  Created by Traci Mathieu on 6/27/18.
//  Copyright © 2018 Traci Mathieu. All rights reserved.
//

#include "PointCloud.hpp"
#import <AssimpKit/SCNScene+AssimpImport.h>
#import <AssimpKit/PostProcessing.h>

// The path to the file path must not be a relative path
NSString *soldierPath = @"/assets/apple/attack.dae";

// Start the import on the given file with some example postprocessing
// Usually - if speed is not the most important aspect for you - you'll
// probably request more postprocessing than we do in this example.
SCNAssimpScene *scene =
[SCNScene assimpSceneWithURL:[NSURL URLWithString:soldierPath]
            postProcessFlags:AssimpKit_Process_FlipUVs |
 AssimpKit_Process_Triangulate]];

// retrieve the SCNView
SCNView *scnView = (SCNView *)self.view;

// set the model scene to the view
scnView.scene = scene.modelScene;


