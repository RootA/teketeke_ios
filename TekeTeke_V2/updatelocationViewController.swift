//
//  updatelocationViewController.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 20/11/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit

import GoogleMaps
import GooglePlaces
import CoreLocation
import CoreData

class updatelocationViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    @IBOutlet weak var updatemapView: GMSMapView!
    var zoomLevel: Float = 15.0
    
    var secondCoordsLat: Double?
    var secondCoordsLng: Double?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBAction func cancelUpdate(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func changeAddress(_ sender: Any) {
        if secondCoordsLat != nil && secondCoordsLng != nil {
            addToDevice(lat: secondCoordsLat!, lng: secondCoordsLng!)
        }else{
            let success_alert = UIAlertController(title: "Error, Identifying new Location", message: "Unable to identify your new location. Do long Tap on your desired new location", preferredStyle: .alert)
            success_alert.addAction(UIAlertAction(title: "OK", style:.default, handler: nil))
            self.present(success_alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updatemapView.delegate = self
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        
        let camera = GMSCameraPosition.camera(withLatitude: -1.298694, longitude: 36.798140, zoom: zoomLevel)
        self.updatemapView.camera = camera
        self.updatemapView.isMyLocationEnabled = true
        
        //Add a Marker
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -1.298694, longitude: 36.798140)
        marker.icon = GMSMarker.markerImage(with: .blue)
        marker.title = "Updating location ... "
        marker.snippet = ""
        marker.map = updatemapView
    }
    
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        // Custom logic here
        let marker = GMSMarker()
        marker.position = coordinate
        marker.title = "Desired Place"
        marker.snippet = ""
        marker.map = mapView
        
        secondCoordsLat = coordinate.latitude
        secondCoordsLng = coordinate.longitude

    }
    
    func addToDevice(lat: Double, lng: Double){
        let newAddress = NSEntityDescription.insertNewObject(forEntityName: "Location", into: context)
        
        newAddress.setValue(lat, forKey: "lat")
        newAddress.setValue(lng, forKey: "lng")
        
        do{
            try context.save()
            
            //show an alert after it successfully added to basket
            let success_alert = UIAlertController(title: "Success", message: "Successfully updated your location, Kindly restart the App for the update to take effect", preferredStyle: .alert)
            success_alert.addAction(UIAlertAction(title: "OK", style:.default, handler: nil))
            self.present(success_alert, animated: true, completion: nil)
            
        }catch{
            return
        }
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

