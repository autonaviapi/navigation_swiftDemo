//
//  NaviViewController.swift
//  AMapDemoSwift
//
//  Created by 王菲 on 15-2-6.
//  Copyright (c) 2015年 autonavi. All rights reserved.
//

import UIKit

class NaviViewController: UIViewController ,MAMapViewDelegate,AMapNaviManagerDelegate,AMapNaviViewControllerDelegate,IFlySpeechSynthesizerDelegate{
    
    var annotations: NSArray?
    var calRouteSuccess: Bool?
    var polyline: MAPolyline?
    var startPoint: AMapNaviPoint?
    var endPoint: AMapNaviPoint?
    var mapView: MAMapView?
    var iFlySpeechSynthesizer: IFlySpeechSynthesizer?
    var naviManager: AMapNaviManager?
    var naviViewController: AMapNaviViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        navigationController?.toolbar.barStyle = UIBarStyle.Black
        
        navigationController?.toolbar.translucent = true
        
        navigationController?.setToolbarHidden(false, animated: true);
        
        
        initToolBar()
        
        configMapView()
        
        initNaviManager()
        
        initAnnotations()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        
        startPoint = AMapNaviPoint.locationWithLatitude(39.989614, longitude: 116.481763);
        endPoint = AMapNaviPoint.locationWithLatitude(39.983456, longitude: 116.315495)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
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
        startBtn.setTitle("模拟导航", forState: UIControlState.Normal)
        startBtn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        startBtn.titleLabel?.font = UIFont.systemFontOfSize(14.0)
        startBtn.addTarget(self, action: "startSimuNavi", forControlEvents: UIControlEvents.TouchUpInside)
        
        view.addSubview(startBtn)
        
    }
    
    
    func initAnnotations(){
        let star = MAPointAnnotation()
        star.coordinate = CLLocationCoordinate2DMake(39.989614,116.481763)
        star.title = "Start"
        
        mapView!.addAnnotation(star)
        
        let end = MAPointAnnotation()
        end.coordinate = CLLocationCoordinate2DMake(39.983456, 116.315495)
        end.title = "End"
        
        mapView!.addAnnotation(end)
        
        annotations = [star,end]
    }
    
    func initToolBar()
    {
        let flexbleItem : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        let calcroute: UIBarButtonItem = UIBarButtonItem(title: "路径规划", style: UIBarButtonItemStyle.Bordered, target: self, action: "calculateRoute")
        
        let simunavi: UIBarButtonItem = UIBarButtonItem(title: "模拟导航", style: UIBarButtonItemStyle.Bordered, target: self, action: "startSimuNavi")
        
        setToolbarItems([flexbleItem,calcroute,flexbleItem,simunavi,flexbleItem], animated: false)
        
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configMapView(){
        
        mapView = MAMapView(frame: self.view.bounds)
        
        mapView!.delegate = self
        
        view.insertSubview(mapView!, atIndex: 0)
        
        if calRouteSuccess == true {
            mapView!.addOverlay(polyline)
            
        }
        
        if(annotations?.count > 0){
            mapView!.addAnnotations(annotations)
        }
    }
    
    func initIFlySpeech(){
        iFlySpeechSynthesizer = IFlySpeechSynthesizer.sharedInstance() as? IFlySpeechSynthesizer
        
        iFlySpeechSynthesizer?.delegate = self
        
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
    
    
    // 模拟导航
    func startSimuNavi()
    {
        if (calRouteSuccess == true) {
            
            initNaviViewController()
            
            naviManager?.presentNaviViewController(naviViewController!, animated: true)
            
        }
        else {
            
            var alert = UIAlertView(title: "请先进行路线规划", message: nil, delegate: nil, cancelButtonTitle: "确定")
            
            alert.show()
            
        }
    }
    
    // 路径规划
    func calculateRoute(){
        
        var startPoints = [AMapNaviPoint]()

        var endPoints = [AMapNaviPoint]()
        
        startPoints.append(startPoint!)
        
        endPoints.append(endPoint!)
        
        var count1 = startPoints.count
        
        
        // 步行路径规划
        // naviManager?.calculateWalkRouteWithStartPoints(startPoints, endPoints: endPoints)
        
        // 驾车路径规划
        naviManager?.calculateDriveRouteWithStartPoints(startPoints, endPoints: endPoints, wayPoints: nil, drivingStrategy: AMapNaviDrivingStrategy.Default)
        
        
    }
    
    // 展示规划路径
    func showRouteWithNaviRoute(naviRoute: AMapNaviRoute)
    {
        if polyline != nil {
            mapView!.removeOverlay(polyline!)
            polyline = nil
        }
        
        let coordianteCount: Int = naviRoute.routeCoordinates.count
        
        var coordinates: [CLLocationCoordinate2D] = []
        
        for var i = 0; i < coordianteCount; i++ {
            var aCoordinate: AMapNaviPoint = naviRoute.routeCoordinates[i] as AMapNaviPoint
            
            coordinates.append(CLLocationCoordinate2DMake(Double(aCoordinate.latitude), Double(aCoordinate.longitude)))
        }
        
        
        polyline = MAPolyline(coordinates:&coordinates, count: UInt(coordianteCount))
        
        mapView!.addOverlay(polyline)
        
    }
    
    // MAMapViewDelegate
    func mapView(mapView: MAMapView!, viewForOverlay overlay: MAOverlay!) -> MAOverlayView! {
        if overlay.isKindOfClass(MAPolyline) {
            let polylineView: MAPolylineView = MAPolylineView(overlay: overlay)
            polylineView.lineWidth = 5.0
            polylineView.strokeColor = UIColor.redColor()
            return polylineView
        }
        return nil
    }
    
    func mapView(mapView: MAMapView!, viewForAnnotation annotation: MAAnnotation!) -> MAAnnotationView! {
        
        if annotation.isKindOfClass(MAPointAnnotation) {
            let annotationIdentifier = "annotationIdentifier"
            
            var poiAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(annotationIdentifier) as? MAPinAnnotationView
            
            if poiAnnotationView == nil {
                poiAnnotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            }
            
            poiAnnotationView!.animatesDrop   = true
            poiAnnotationView!.canShowCallout = true
            
            return poiAnnotationView;
        }
        return nil
    }
    
    
    // AMapNaviManagerDelegate
    // 算路成功回调
    func naviManagerOnCalculateRouteSuccess(naviManager: AMapNaviManager!) {
        println("success")
        
        showRouteWithNaviRoute(naviManager.naviRoute);
        
        calRouteSuccess = true
        
    }
    
    // 展示导航视图回调
    func naviManager(naviManager: AMapNaviManager!, didPresentNaviViewController naviViewController: UIViewController!) {
        println("success")
        initIFlySpeech()
        naviManager.startEmulatorNavi()
    }
    
    // 导航播报信息回调
    func naviManager(naviManager: AMapNaviManager!, playNaviSoundString soundString: String!, soundStringType: AMapNaviSoundType) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),{
            self.iFlySpeechSynthesizer?.startSpeaking(soundString)
            println("start speak");
        });
        
    }
    
    
    // AMapNaviViewControllerDelegate
    // 导航界面关闭按钮点击的回调
    func naviViewControllerCloseButtonClicked(naviViewController: AMapNaviViewController!) {
        iFlySpeechSynthesizer?.stopSpeaking()
        iFlySpeechSynthesizer?.delegate = nil
        iFlySpeechSynthesizer = nil
        naviManager?.stopNavi()
        naviManager?.dismissNaviViewControllerAnimated(true)
        
        configMapView()
    }
    
    // 导航界面更多按钮点击的回调
    func naviViewControllerMoreButtonClicked(naviViewController: AMapNaviViewController!) {
        if naviViewController.viewShowMode == AMapNaviViewShowMode.CarNorthDirection {
            naviViewController.viewShowMode = AMapNaviViewShowMode.MapNorthDirection
            
        }
        else {
            naviViewController.viewShowMode = AMapNaviViewShowMode.CarNorthDirection
        }
    }
    
    // 导航界面转向指示View点击的回调
    func naviViewControllerTurnIndicatorViewTapped(naviViewController: AMapNaviViewController!){
        naviManager?.readNaviInfoManual()
    }
    
    // IFlySpeechSynthesizerDelegate
    func onCompleted(error: IFlySpeechError!) {
        println("IFly error\(error)")
    }
    
}
