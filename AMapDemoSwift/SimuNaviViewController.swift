//  ViewController.swift
//
//  AMapDemoSwift
//
//  Created by 王菲 on 15-1-22.
//  Copyright (c) 2015年 autonavi. All rights reserved.
//

import UIKit

class SimuNaviViewController: UIViewController ,MAMapViewDelegate,AMapNaviManagerDelegate,AMapNaviViewControllerDelegate{
    
    var mapView:MAMapView?
    var naviManager: AMapNaviManager?
    var naviViewController:AMapNaviViewController?
    var startPoint: AMapNaviPoint?
    var endPoint: AMapNaviPoint?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        configSubViews()
        
        initMapView()
        
        initNaviManager()
        
        initNaviViewController()
        
        
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        
        startPoint = AMapNaviPoint.locationWithLatitude(39.989614, longitude: 116.481763);
        endPoint = AMapNaviPoint.locationWithLatitude(39.983456, longitude: 116.315495)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func  configSubViews() {
        
        var startPointLabel = UILabel(frame: CGRectMake(0, 100, 320, 20))
        
        startPointLabel.textAlignment = NSTextAlignment.Center
        startPointLabel.font = UIFont.systemFontOfSize(14)
        let startLatitude = startPoint?.latitude.description
        let startLongitude = startPoint?.longitude.description
        startPointLabel.text = "起点:" + startLatitude! + "," + startLongitude!
        
        view.addSubview(startPointLabel)
        
        
        var endPointLabel = UILabel(frame: CGRectMake(0, 130, 320, 20))
        
        endPointLabel.textAlignment = NSTextAlignment.Center
        endPointLabel.font = UIFont.systemFontOfSize(14)
        let endLatitude = endPoint?.latitude.description
        let endLongitude = endPoint?.longitude.description
        endPointLabel.text = "终点:" + endLatitude! + "," + endLongitude!
        view.addSubview(endPointLabel)
        
        
        var startBtn = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        startBtn.layer.borderColor = UIColor.lightGrayColor().CGColor
        startBtn.layer.borderWidth = 0.5
        startBtn.layer.cornerRadius = 5
        
        startBtn.frame = CGRectMake(60, 160, 200, 30)
        startBtn.setTitle("一键导航", forState: UIControlState.Normal)
        startBtn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        startBtn.titleLabel?.font = UIFont.systemFontOfSize(14.0)
        startBtn.addTarget(self, action: "startSimuNavi", forControlEvents: UIControlEvents.TouchUpInside)
        
        view.addSubview(startBtn)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func initMapView(){
        mapView = MAMapView(frame: self.view.bounds)
        mapView!.delegate = self
        
    }
    
    
    func initNaviManager(){
        if (naviManager == nil) {
            naviManager = AMapNaviManager()
            naviManager?.delegate = self
        }
    }
    
    
    func initNaviViewController(){
        if(naviViewController == nil){
            naviViewController = AMapNaviViewController(mapView: mapView!, delegate: self)
        }
        
    }
    
    func startSimuNavi(){
        
        var startPoints = [AMapNaviPoint]()
        
        var endPoints = [AMapNaviPoint]()
        
        startPoints.append(startPoint!)
        
        endPoints.append(endPoint!)
        
        naviManager?.calculateDriveRouteWithStartPoints(startPoints, endPoints: endPoints, wayPoints: nil, drivingStrategy: AMapNaviDrivingStrategy.Default)
        
    }
    
    
    // AMapNaviManagerDelegate
    func naviManagerOnCalculateRouteSuccess(naviManager: AMapNaviManager!) {
        println("success")
        naviManager.presentNaviViewController(naviViewController!, animated: true)
    }
    
    func naviManager(naviManager: AMapNaviManager!, didPresentNaviViewController naviViewController: UIViewController!) {
        println("success")
        naviManager.startEmulatorNavi()
    }
    
    
    // AMapNaviViewControllerDelegate
    func naviViewControllerCloseButtonClicked(naviViewController: AMapNaviViewController!) {
        naviManager?.stopNavi()
        naviManager?.dismissNaviViewControllerAnimated(true)
    }
}

