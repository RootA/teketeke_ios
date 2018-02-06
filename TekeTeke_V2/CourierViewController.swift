//
//  CourierViewController.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 13/11/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit

import GoogleMaps
import GooglePlaces


class CourierViewController: UIViewController, GMSMapViewDelegate {

    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    var secondCoordsLat: Double?
    var secondCoordsLng: Double?
    
    @IBOutlet weak var googlemapView: GMSMapView!
    
//    @IBOutlet weak var placesView: UIView!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.googlemapView.delegate = self
        
        let camera = GMSCameraPosition.camera(withLatitude: -1.298694 , longitude: 36.798140, zoom: 12)
        self.googlemapView.camera = camera
        self.googlemapView.isMyLocationEnabled = true
        
        let currentLocation = CLLocationCoordinate2D(latitude: -1.298694, longitude: 36.798140)
        let marker = GMSMarker(position: currentLocation)
        marker.icon = GMSMarker.markerImage(with: .black)
        marker.map = googlemapView
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (identifier == "courierSegue") {
            if (secondCoordsLat != nil) && (secondCoordsLng != nil) {
                return true
            } else {
                let alert_msg = UIAlertController(title: "Location Not Found", message: "Do a long press on the desired location", preferredStyle: .alert)
                alert_msg.addAction(UIAlertAction(title: "OK", style:.default, handler: nil))
                self.present(alert_msg, animated: true, completion: nil)
                return false
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "courierSegue") {
            if (secondCoordsLat != nil) && (secondCoordsLng != nil) {
                let vc = segue.destination as! CourierCostViewController
                
                vc.lat = secondCoordsLat
                vc.lng = secondCoordsLng
                
            }
        }
    }

//

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CourierViewController: CLLocationManagerDelegate {
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            locationManager.allowsBackgroundLocationUpdates = true
            googlemapView.isMyLocationEnabled = true
            googlemapView.settings.myLocationButton = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            googlemapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            locationManager.stopUpdatingLocation()
        }
        
    }
}


