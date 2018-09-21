//
//  ViewController.swift
//  3D City App
//
//  Created by Traci Mathieu on 6/10/18.
//  Copyright © 2018 Traci Mathieu. All rights reserved.
//

import UIKit
import ARKit
import Alamofire
import AlamofireImage
import ReplayKit
import DropDown

class ViewController: UIViewController, ARSCNViewDelegate, RPPreviewViewControllerDelegate, ObjectDelegate, ScaleDelegate, DataDelegate, BuildingDelegate {
       
    @IBOutlet weak var sceneView: ARSCNView!
    
    // create a button to record footage of the AR view
    let videoButton = UIButton()
    var videoImageScaled = UIImage()
    var shadedVideoImageScaled = UIImage()
    private var isRecording = false
    
    let dataLabel = UILabel()
       
    let plusButton = UIButton()
    let plusDropDown = DropDown()
        
    let undoButton = UIButton()
    
    let recorder = RPScreenRecorder.shared()
    
    // min and max height for coloring the data
    var min = Double.infinity
    var max = -Double.infinity
    
    // is there a city model in the AR view?
    var cityIsSet = false
    
    // nodes for the 3D city model
    let parentNode = SCNNode()
    let dataaParentNode = SCNNode()
    let databParentNode = SCNNode()
    let co2ParentNode = SCNNode()
    let humParentNode = SCNNode()
    let tempParentNode = SCNNode()
    
    // scenes for each of the .dae files, change as necessary
       
    let buildingScene = SCNScene(named: "buildings.dae")
    let waterScene = SCNScene(named: "water.dae")
    let roadScene = SCNScene(named: "roads.dae")
    let grassScene = SCNScene(named: "grass.dae")
    let pathScene = SCNScene(named: "pedestrianpath.dae")
    let surfaceScene = SCNScene(named: "surfaces.dae")
       
    // show data button
    let enableModel = UISwitch()
       
    var objectView = ObjectModeView()
    var scaleView = ScaleModeView()
    var dataView = DataModeView()
    var buildingView = BuildingModeView()
    var undoActionHelper = UndoActionHelper()
        
    var difference = 0.0
    
    //////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGestureToSceneView()
       
        objectView = ObjectModeView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        scaleView = ScaleModeView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        dataView = DataModeView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        buildingView = BuildingModeView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
       
        NotificationCenter.default.addObserver(self, selector: #selector(rotate), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
       
        objectView.setUpButtons()
        scaleView.setUpButtons()
        dataView.setUpButtons()
        buildingView.setUpButtons()
       
        objectView.delegate = self
        scaleView.delegate = self
        dataView.delegate = self
        buildingView.delegate = self
       
        objectView.isHidden = true
        scaleView.isHidden = true
        dataView.isHidden = true
        buildingView.isHidden = true
       
        self.view.addSubview(scaleView)
        self.view.addSubview(objectView)
        self.view.addSubview(dataView)
        self.view.addSubview(buildingView)
      
        // set up button for video camera
        videoButton.setTitle("Video", for: .normal)
        let size = CGSize(width: 50.0, height: 50.0)
        let videoImage = UIImage(named: "camera")!
        videoImageScaled = videoImage.af_imageAspectScaled(toFit: size)
        let shadedVideoImage = UIImage(named: "cam shaded")
        shadedVideoImageScaled = shadedVideoImage!.af_imageAspectScaled(toFit: size)
        videoButton.setTitleColor(UIColor.clear, for: [])
        videoButton.setImage(videoImageScaled, for: [])
        videoButton.addTarget(self, action: #selector(self.tapButton(_:)), for: .touchUpInside)
        sceneView.addSubview(videoButton)
       
        // set up the button for enabling and disabling model interaction
        enableModel.setOn(true, animated: false)
        // switch is disabled at the beginning because there is no city model set
        enableModel.isEnabled = false
        enableModel.tintColor = UIColor.black
        enableModel.onTintColor = UIColor.black
        sceneView.addSubview(enableModel)
       
        // set up the label for the data
        dataLabel.font = UIFont.systemFont(ofSize: 18)
        dataLabel.textAlignment = .left
        dataLabel.textColor = UIColor.white
        dataLabel.numberOfLines = 4
        sceneView.addSubview(dataLabel)
        
        // add constraints for the data label
        dataLabel.translatesAutoresizingMaskIntoConstraints = false
        sceneView.addConstraint(NSLayoutConstraint(item: dataLabel, attribute: .top, relatedBy: .equal, toItem: sceneView, attribute: .top, multiplier: 1, constant: 35))
        sceneView.addConstraint(NSLayoutConstraint(item: dataLabel, attribute: .centerX, relatedBy: .equal, toItem: sceneView, attribute: .centerX, multiplier: 1, constant: 0))
        
        // add constraints for the show data button
        videoButton.translatesAutoresizingMaskIntoConstraints = false
        sceneView.addConstraint(NSLayoutConstraint(item: videoButton, attribute: .top, relatedBy: .equal, toItem: sceneView, attribute: .top, multiplier: 1, constant: 20))
        sceneView.addConstraint(NSLayoutConstraint(item: videoButton, attribute: .trailing, relatedBy: .equal, toItem: sceneView, attribute: .trailing, multiplier: 1, constant: 30))
        
        // add constraints for the video button
        enableModel.translatesAutoresizingMaskIntoConstraints = false
        sceneView.addConstraint(NSLayoutConstraint(item: enableModel, attribute: .top, relatedBy: .equal, toItem: sceneView, attribute: .top, multiplier: 1, constant: 30))
        sceneView.addConstraint(NSLayoutConstraint(item: enableModel, attribute: .leading, relatedBy: .equal, toItem: sceneView, attribute: .leading, multiplier: 1, constant: 20))
       
        // set up the icon to access different modes
        plusButton.setTitle("", for: .normal)
        plusButton.setTitleColor(UIColor.clear, for: .normal)
        let plusImage = UIImage(named: "plus.png")!
        let plusImageScaled = plusImage.af_imageAspectScaled(toFit: size)
        plusButton.setImage(plusImageScaled, for: [])
        plusButton.addTarget(self, action: #selector(self.tapButton(_:)), for: .touchUpInside)
        plusButton.isHidden = true
        sceneView.addSubview(plusButton)
       
        // set up drop down menu for plus button
        plusDropDown.anchorView = plusButton
        plusDropDown.dataSource = ["Object Mode", "Data Mode", "Buildings Mode", "Scale Mode", "Reset Model"]
        plusDropDown.selectionBackgroundColor = UIColor.lightGray
        plusDropDown.topOffset = CGPoint(x: -35, y: 0)
        plusDropDown.cellHeight = 40

       // action triggered on selection
       plusDropDown.selectionAction = { (index, item) in
              if item == "Object Mode" {
                     self.objectView.isHidden = false
                     self.plusButton.isHidden = true
                     print("Object Mode")
              }
              else if item == "Data Mode" {
                     self.dataView.isHidden = false
                     self.plusButton.isHidden = true
                     print("Data Mode")
              }
              else if item == "Buildings Mode" {
                     self.buildingView.isHidden = false
                     self.plusButton.isHidden = true
                     print("Buildings Mode")
              }
              else if item == "Scale Mode" {
                     self.scaleView.isHidden = false
                     self.plusButton.isHidden = true
                     print("Scale Mode")
              }
              else if item == "Reset Model" {
                
                // pop-up warning
                let alert = UIAlertController(title: "Reset Model?", message: "Are you sure you want to reset this 3D city model? All changes will be lost.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Reset", style: UIAlertActionStyle.destructive, handler: { action in
                        // do something like...
                        print("destructive")
                        let nodeArrays = self.undoActionHelper.resetCityModel()
                        let originalNodes = nodeArrays.0
                        let changedNodes = nodeArrays.1
                        
                        for index in 0...originalNodes.count-1 {
                                
                                if let originalNode = originalNodes[index] {
                                        if let parent = changedNodes[index].parent {
                                                // originalNode.worldPosition = changedNodes[index].worldPosition
                                                // parent.addChildNode(originalNode)
                                        }
                                }

                                changedNodes[index].removeFromParentNode()
                        }
                        
                        // reset undo action helper
                        self.undoActionHelper.reset()
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
                        // do something like...
                        print("cancel")
                        return
                }))
                self.present(alert, animated: true, completion: nil)
                
                // remove every SCNNode from the view using array
                self.sceneView.scene.rootNode.enumerateChildNodes { (existingNode, _) in
                        // existingNode.removeFromParentNode()
                     }
              }
        }
       
        // set up the constraints for the plus button
        
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        sceneView.addConstraint(NSLayoutConstraint(item: plusButton, attribute: .bottom, relatedBy: .equal, toItem: sceneView, attribute: .bottom, multiplier: 1, constant: -15))
        sceneView.addConstraint(NSLayoutConstraint(item: plusButton, attribute: .centerX, relatedBy: .equal, toItem: sceneView, attribute: .centerX, multiplier: 1, constant: 0))
        
        // set up the undo button and the constraints
        undoButton.setTitle("", for: .normal)
        undoButton.setTitleColor(UIColor.clear, for: .normal)
        let undoImage = UIImage(named: "undo.png")!
        let undoImageScaled = undoImage.af_imageAspectScaled(toFit: size)
        undoButton.setImage(undoImageScaled, for: [])
        undoButton.addTarget(self, action: #selector(self.tapButton(_:)), for: .touchUpInside)
        // undoButton.isHidden = true
        sceneView.addSubview(undoButton)
        
        undoButton.translatesAutoresizingMaskIntoConstraints = false
        sceneView.addConstraint(NSLayoutConstraint(item: undoButton, attribute: .top, relatedBy: .equal, toItem: sceneView, attribute: .top, multiplier: 1, constant: 20))
        sceneView.addConstraint(NSLayoutConstraint(item: undoButton, attribute: .centerX, relatedBy: .equal, toItem: sceneView, attribute: .centerX, multiplier: 1, constant: 0))
      
        // set up the model
        setUpCityModel()
    }
       
       @objc func rotate()
       {
              objectView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
              scaleView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
              dataView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
              buildingView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
       }
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.addCityToSceneView(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        let doubleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.numberOfTouchesRequired = 1
        sceneView.addGestureRecognizer(doubleTap)
    }
    
    // function for recognizing whether a LocationAnnotationNode was tapped
    @objc func handleDoubleTap(_ gestureRecognizer : UITapGestureRecognizer) {
        
        guard gestureRecognizer.view != nil else { return }
        
        let point = gestureRecognizer.location(in: sceneView)
        let hitResults = sceneView.hitTest(point, options: [:])
        for hit in hitResults {
            if let info = hit.node.name {
                if gestureRecognizer.state == .ended {
                    if info == "Building" {
                     
                     if buildingView.isHidden == true {
                            return
                     }
                     
                     print("change building")
              
                     let correctHeight = Double(parentNode.convertPosition(parentNode.boundingBox.min, to: nil).y)
                     
                     hit.node.removeFromParentNode()
              
                     let newNode = buildingView.changeBuilding(node: hit.node)
                     // need to add new node to parentNode to update the coordinate system
                     parentNode.addChildNode(newNode)
                     
                     let newHeight = Double(newNode.convertPosition(newNode.boundingBox.min, to: nil).y)
                            if difference == 0.0 {
                                   difference = abs(correctHeight - newHeight)
                            }
                     
                            if buildingView.buildingMode == "Scale" {
                                   newNode.worldPosition.y = parentNode.worldPosition.y + Float(difference)
                            }
                    
                    undoActionHelper.addAction(originalNode: hit.node, changedNode: newNode)
                    
                    }
                    else if info == "Grass" || info == "Surface" || info == "Path" {
                     
                     if objectView.isHidden == true {
                            return
                     }
                        
                     let objectNode = objectView.addObject(position: hit.node.convertPosition(hit.localCoordinates, to: parentNode))
                
                     parentNode.addChildNode(objectNode)
                     undoActionHelper.addAction(originalNode: nil, changedNode: objectNode)

                    }
                    else if info != "Cylinder" && info != "bush" && info != "Cylinder01" {
                     let textTodraw = SCNText(string: "\(info)", extrusionDepth: 0.5)
                     textTodraw.firstMaterial?.diffuse.contents = UIColor.white
                     let textNode = SCNNode(geometry: textTodraw)
                     // parentNode.addChildNode(textNode)
                     hit.node.addChildNode(textNode)
                     textNode.position = hit.node.convertPosition(hit.node.boundingBox.max, to: nil)
                     textNode.position.y = textNode.position.y + 1.0
                     //textNode.position = hit.node.convertPosition(hit.node.boundingBox.max, to: parentNode)
                     textNode.scale = SCNVector3(500, 500, 500)
                     textNode.eulerAngles = SCNVector3(Double.pi / 2, 0, 0)
                     undoActionHelper.addAction(originalNode: nil, changedNode: textNode)
                     dataLabel.text = "\(info)"
                    }
                }
            }
        }
    }
    
    @objc func tapButton(_ sender: UIButton) {
        if sender == videoButton {
            if isRecording == false {
                // self.statusLabel.text = "Recording..."
                // self.statusLabel.textColor = UIColor.red
                videoButton.setImage(shadedVideoImageScaled, for: .normal)
                startRecording()
            }
            else {
                stopRecording()
            }
            print("recording footage of AR view")
        }
        else if sender == plusButton {
            plusDropDown.show()
        }
        else if sender.currentTitle == "1:10⁵" {
            // let unscaledParentNode = parentNode
            parentNode.scale = SCNVector3(0.000001, 0.000001, 0.000001)
            // undoActionHelper.addAction(originalNode: unscaledParentNode, changedNode: parentNode)
        }
        else if sender.currentTitle == "1:10⁴" {
            // let unscaledParentNode = parentNode
            parentNode.scale = SCNVector3(0.00001, 0.00001, 0.00001)
            // undoActionHelper.addAction(originalNode: unscaledParentNode, changedNode: parentNode)
        }
        else if sender.currentTitle == "1:10²" {
            // let unscaledParentNode = parentNode
            parentNode.scale = SCNVector3(0.001, 0.001, 0.001)
            // undoActionHelper.addAction(originalNode: unscaledParentNode, changedNode: parentNode)
        }
        else if sender == enableModel {
        }
        else if sender.currentTitle == "Exit" {
              plusButton.isHidden = false
              objectView.isHidden = true
              dataView.isHidden = true
              scaleView.isHidden = true
              buildingView.isHidden = true
       }
        else if sender.currentTitle == "Data A" {
              dataaParentNode.isHidden = false
              databParentNode.isHidden = true
              humParentNode.isHidden = true
              tempParentNode.isHidden = true
              co2ParentNode.isHidden = true
       }
        else if sender.currentTitle == "Data B" {
              dataaParentNode.isHidden = true
              databParentNode.isHidden = false
              humParentNode.isHidden = true
              tempParentNode.isHidden = true
              co2ParentNode.isHidden = true
       }
        else if sender.currentTitle == "Temp" {
              dataaParentNode.isHidden = true
              databParentNode.isHidden = true
              humParentNode.isHidden = true
              tempParentNode.isHidden = false
              co2ParentNode.isHidden = true
              
        }
        else if sender.currentTitle == "Hum" {
              dataaParentNode.isHidden = true
              databParentNode.isHidden = true
              humParentNode.isHidden = false
              tempParentNode.isHidden = true
              co2ParentNode.isHidden = true
        }
        else if sender.currentTitle == "CO2" {
              dataaParentNode.isHidden = true
              databParentNode.isHidden = true
              humParentNode.isHidden = true
              tempParentNode.isHidden = true
              co2ParentNode.isHidden = false
        }
        else if sender.currentTitle == "None" {
              dataaParentNode.isHidden = true
              databParentNode.isHidden = true
              humParentNode.isHidden = true
              tempParentNode.isHidden = true
              co2ParentNode.isHidden = true
       }
       
}
    
    // start recording
    func startRecording() {
        guard recorder.isAvailable else {
            print("Recording is not available at this time.")
            return
        }
    
        recorder.startRecording { [unowned self] (error) in
            
            guard error == nil else {
                print("There was an error starting the recording.")
                return
            }
            
            print("Started Recording Successfully")
            // self.micToggle.isEnabled = false
            self.isRecording = true
    }
}
    
    // save footage and stop recording
    func stopRecording() {

        // call function to stop recording
        recorder.stopRecording { [unowned self] (preview, error) in
            print("Stopped recording")
            
            guard preview != nil else {
                print("Preview controller is not available.")
                return
            }
            
            let alert = UIAlertController(title: "Recording Finished", message: "Would you like to edit or delete your recording?", preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction) in
                self.recorder.discardRecording(handler: { () -> Void in
                    print("Recording deleted.")
                })
            })
            
            let editAction = UIAlertAction(title: "Edit", style: .default, handler: { (action: UIAlertAction) -> Void in
                preview?.previewControllerDelegate = self
                self.present(preview!, animated: true, completion: nil)
            })
            
            alert.addAction(editAction)
            alert.addAction(deleteAction)
            self.present(alert, animated: true, completion: nil)
            
            self.isRecording = false
            self.videoButton.setImage(self.videoImageScaled, for: [])
            
        }
    }
    
    // dismisses the preview controller after user edits the footage
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        dismiss(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpSceneView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func setUpSceneView() {
        
        // sets up the AR view
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        sceneView.session.run(configuration)
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
    }
    
    // colors the data
    func colorData(value: Double) -> UIColor {
        
        let newMin = 0.0
        let newMax = 1.0

        let oldRange = (max - min)
        let newRange = newMax - newMin
        
        let newValue = (((value - min) * newRange) / oldRange) + newMin
        let red = newValue
        let green = 1 - newValue
        
        // create color based on the height
        let newColor = UIColor(red: (CGFloat(red)), green: (0.25), blue: (CGFloat(green)), alpha: 1.0)
        
        return newColor
    }
    
    func setUpCityLayer(scene: SCNScene, color: UIColor) {
        // create array of child nodes for the city layer
        let layerArray = scene.rootNode.childNodes
        
        // create material for the city layer
        let layerMaterial = SCNMaterial()
        layerMaterial.diffuse.contents = color
        
        // apply material and add city layer to the 3D model
        for childNode in layerArray {
            childNode.geometry?.materials = [layerMaterial]
              
       // assign names to each of the nodes
            if scene == buildingScene {
                childNode.name = "Building"
            }
            else if scene == grassScene {
                childNode.name = "Grass"
            }
            else if scene == surfaceScene {
                  childNode.name = "Surface"
            }
            else if scene == pathScene {
                  childNode.name = "Path"
            }
            parentNode.addChildNode(childNode)
        }
    }
    
    // sets up the air quality data
    func setUpData(scene: SCNScene, dataParentNode: SCNNode) {
        let dataArray = scene.rootNode.childNodes
        
        // find the max and min height for the data
        for node in dataArray {
            if Double(node.boundingBox.max.z) < min {
                min = Double(node.boundingBox.max.z)
            }
            if Double(node.boundingBox.max.z) > max {
                max = Double(node.boundingBox.max.z)
            }
        }
        
        // apply color gradient to the data based on height
        for childNode in dataArray {
            let dataMaterial = SCNMaterial()
                
            dataMaterial.diffuse.contents = colorData(value: Double(childNode.boundingBox.max.z))
            
            let sphereGeometry = SCNSphere(radius: CGFloat(childNode.boundingBox.max.z - childNode.boundingBox.min.z) * 0.25)
            let sphereNode = SCNNode()
            sphereNode.geometry = sphereGeometry
            sphereNode.geometry?.materials = [dataMaterial]
              
            sphereNode.position = childNode.convertPosition(childNode.boundingBox.max, to: scene.rootNode)
            // assign data point to each box as the name of the node
            // ** random data **
            sphereNode.name = "\(arc4random_uniform(90) + 10)"
            dataParentNode.addChildNode(sphereNode)
        }
        
        // data is hidden by default
        dataParentNode.isHidden = true
        
        // reset the min and max
        min = Double.infinity
        max = -Double.infinity
    }
    
    func setUpCityModel() {
        
        // load the scene for each data set, change as necessary
        let dataaScene = SCNScene(named: "dataa.dae")
        let databScene = SCNScene(named: "datab.dae")
       
       let co2Scene = SCNScene(named: "CO2data.dae")
       let humScene = SCNScene(named: "Humidity.dae")
       let tempScene = SCNScene(named: "TempData.dae")
        
        // set up the data
        setUpData(scene: dataaScene!, dataParentNode: dataaParentNode)
        setUpData(scene: databScene!, dataParentNode: databParentNode)
        setUpData(scene: co2Scene!, dataParentNode: co2ParentNode)
        setUpData(scene: humScene!, dataParentNode: humParentNode)
        setUpData(scene: tempScene!, dataParentNode: tempParentNode)
        
        // city up the city layers
        setUpCityLayer(scene: waterScene!, color: UIColor(red: (160/255.0), green: (252/255.0), blue: (253/255.0), alpha: 1.0))
        setUpCityLayer(scene: buildingScene!, color: UIColor(red: (230/255.0), green: (181/255.0), blue: (195/255.0), alpha: 1.0))
        setUpCityLayer(scene: roadScene!, color: UIColor(red: (100/255.0), green: (100/255.0), blue: (100/255.0), alpha: 1.0))
        setUpCityLayer(scene: pathScene!, color: UIColor(red: (194/255.0), green: (211/255.0), blue: (194/255.0), alpha: 1.0))
        setUpCityLayer(scene: surfaceScene!, color: UIColor(red: (223/255.0), green: (223/255.0), blue: (223/255.0), alpha: 1.0))
        setUpCityLayer(scene: grassScene!, color: UIColor(red: (183/255.0), green: (255/255.0), blue: (124/255.0), alpha: 1.0))
        
        // add the data to the 3D model
        parentNode.addChildNode(dataaParentNode)
        parentNode.addChildNode(databParentNode)
        parentNode.addChildNode(co2ParentNode)
        parentNode.addChildNode(humParentNode)
        parentNode.addChildNode(tempParentNode)
        
        // scale the 3D city model and change the angle
        parentNode.eulerAngles = SCNVector3(-Double.pi / 2, 0, 0)
        parentNode.scale = SCNVector3(0.000001, 0.000001, 0.000001)
    }
    
    @objc func addCityToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {

        // edit mode, cannot add or delete city from scene
        if enableModel.isOn == false {
            return
        }

        let tapLocation = recognizer.location(in: sceneView)
        
        // update camera if necessary
        if self.isRecording == false {
            videoButton.setImage(videoImageScaled, for: .normal)
        }
        
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        guard let hitTestResult = hitTestResults.first else { return }
        
        // add 3D city model or remove existing 3D city model from view
        if cityIsSet == true {
            sceneView.isUserInteractionEnabled = false
            
            self.sceneView.scene.rootNode.enumerateChildNodes { (existingNode, _) in
                if existingNode == parentNode {
                    existingNode.removeFromParentNode()
                    enableModel.isEnabled = false
                }
            }
            plusButton.isHidden = true
            dataaParentNode.isHidden = true
            databParentNode.isHidden = true
            humParentNode.isHidden = true
            tempParentNode.isHidden = true
            co2ParentNode.isHidden = true
            objectView.isHidden = true
            scaleView.isHidden = true
            dataView.isHidden = true
            buildingView.isHidden = true
            cityIsSet = false
            sceneView.isUserInteractionEnabled = true
            return
        }
        else {
            plusButton.isHidden = false
            cityIsSet = true
        }
        
        let translation = hitTestResult.worldTransform.translation
        let x = translation.x
        let y = translation.y
        let z = translation.z
        
        // change the position of the 3D city model and add 3D city model to the AR view
        parentNode.position = SCNVector3(x,y,z)
        enableModel.isEnabled = true
        sceneView.scene.rootNode.addChildNode(parentNode)

    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
       
       // there is a 3D city in the view, anchor planes cannot be added
       if cityIsSet {
          return
       }

        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        // makes the plane for the anchor clear
        plane.materials.first?.diffuse.contents = UIColor.clear
        
        let planeNode = SCNNode(geometry: plane)
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        
        node.addChildNode(planeNode)
    
    }
    
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}
