//
//  CourierCostViewController.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 25/11/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit
import CoreLocation

class CourierCostViewController: UIViewController, CLLocationManagerDelegate, UIScrollViewDelegate {
    
//    var lat_origin: Double?
//    var lng_origin: Double?
    let locationManager = CLLocationManager()
    var lat: Double?
    var lng: Double?
    
    @IBOutlet weak var estimateprice: UILabel!
    @IBAction func requestRider(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set the delegate to be the one current
        isAuthorizedtoGetUserLocation()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        }
    }
    
    func getPrice(lat_origin: Double, lng_origin: Double){
        let coordinates0 = CLLocation(latitude: lat_origin, longitude: lng_origin)
        let coordinates1 = CLLocation(latitude: lat!, longitude: lng!)
        
        let distanceInMeters = coordinates0.distance(from: coordinates1)
        
        if Int(distanceInMeters) < ApiService.sharedInstance.basic_delivery_km {
            self.estimateprice.text = "KSH \(ApiService.sharedInstance.delivery_fee_for_4km)"
        }else {
            //check by how many meters it has exceeded the basic milage
            let diff_in_distance = Int(distanceInMeters) - ApiService.sharedInstance.basic_delivery_km
            if diff_in_distance > ApiService.sharedInstance.basic_delivery_km {
                let price = diff_in_distance/1000 * 30
                self.estimateprice.text = "KSH \(price + ApiService.sharedInstance.delivery_fee_for_4km)"
            }
        }
    }
    
    //if we have no permission to access user location, then ask user for permission.
    func isAuthorizedtoGetUserLocation() {
        
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse     {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    
    //this method will be called each time when a user change his location access preference.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            print("User allowed us to access location")
            //do whatever init activities here.
            let locValue: CLLocationCoordinate2D = (manager.location?.coordinate)!
            getPrice(lat_origin: locValue.latitude, lng_origin: locValue.longitude)
        }
    }
    
    
    //this method is called by the framework on  locationManager.requestLocation();
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Did location updates is called")
        //store the user location here to firebase or somewhere
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Did location updates is called but failed getting location \(error)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
