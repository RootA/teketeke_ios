//
//  OutletFeedViewController.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 16/09/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit
import CoreLocation

class OutletFeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, CLLocationManagerDelegate {

    var outlets: [Outlet] = []
    var categorySlug: String?
    var categoryName: String?
    let activityIndicatorCustom = ActivityIndicator()
    @IBOutlet weak var outletCollectionView: UICollectionView!
    
    let locationManager = CLLocationManager()
    
    var global_lat : Double?
    var global_lng : Double?
    
    var distance_to_price: String?

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
            
            global_lat = locValue.latitude
            global_lng = locValue.longitude
            
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        fectchCategoryOutlets()
    }
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
       navigationItem.title = categoryName!
       navigationController?.navigationBar.tintColor = UIColor.init(red: 255/255, green: 0/255, blue: 128/255, alpha: 1)
        
        //set the delegate to be the one current
        isAuthorizedtoGetUserLocation()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        }
    }
    
    
    func fectchCategoryOutlets(){
        activityIndicatorCustom.show()
        outlets = []
        let get_categories_url = URL(string: "\(ApiService.sharedInstance.baseUrl)outlets/type/\(categorySlug!)")
        
        URLSession.shared.dataTask(with: get_categories_url!) { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            let options = JSONSerialization.ReadingOptions.mutableContainers
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: options) as AnyObject
                let image_url = json["image_url"] as! String
                
                
                if let outlets_info = json["outlets"] as! NSArray? {
                    
                    if (outlets_info.count < 1){
                        DispatchQueue.main.async {
                            self.activityIndicatorCustom.hide()
                        }
                        //alter the maintable view to show the user that no data has been found
                        let success_alert = UIAlertController(title: "No Outlets Found", message: "Apologies No Outlets From \(self.navigationItem.title!) is Currently Listed at the Moment", preferredStyle: .alert)
                        success_alert.addAction(UIAlertAction(title: "OK", style:.default, handler: {(action) in self.loadHome()}))
                        self.present(success_alert, animated: true, completion: nil)
                    }else {
                        for data in outlets_info {
                            let tdata = data as? [String : AnyObject]
                            let outlet_name = tdata?["name"] as? String ?? " "
                            let _ = tdata?["coordinates"] as! String
                            let outlet_lat = tdata?["lat"] as! String
                            let outlet_lng = tdata?["lng"] as! String
                            let outlet_desc = tdata?["description"] as? String ?? " "
                            let outlet_slug = tdata?["slug"] as! String
                            let outlet_caption = tdata?["caption"] as? String ?? " "
                            let outlet_banner = tdata?["banner"] as? String ?? " "
                            let outlet_logo = tdata?["logo"] as? String ?? " "
                            
                            let coordinates0 = CLLocation(latitude: self.global_lat!, longitude: self.global_lng!)
                            let coordinates1 = CLLocation(latitude: Double(outlet_lat)!, longitude: Double(outlet_lng)!)
                            
                            let distanceInMeters = coordinates0.distance(from: coordinates1)
                            
                            
                            
                            if Int(distanceInMeters) < ApiService.sharedInstance.basic_delivery_km {
                                self.distance_to_price = "\(ApiService.sharedInstance.delivery_fee_for_4km)"
                            }else {
                                //check by how many meters it has exceeded the basic milage
                                let diff_in_distance = Int(distanceInMeters) - ApiService.sharedInstance.basic_delivery_km
                                let price = diff_in_distance/1000 * 30
                                self.distance_to_price = "\(price + ApiService.sharedInstance.delivery_fee_for_4km)"
                            }
                            
                            let image_string = image_url+outlet_banner
                            //append the data to the outlets array
                            self.outlets.append(Outlet(outletName: outlet_name, outletCaption: outlet_caption, outletBannerImage: image_string, outletLogoImage: outlet_logo, outletMilage: self.distance_to_price!, outletDescription: outlet_desc, outletSlug: outlet_slug))
                        }
                        //
                        DispatchQueue.main.async {
                            self.activityIndicatorCustom.hide()
                            self.outletCollectionView?.reloadData()
                        }
                    }
                }
            } catch(let parseError){
                print("There was an error parsing the JSON: \"\(parseError.localizedDescription)\"")
            }
            }.resume()
        
    }
    
    func loadHome(){
        navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return outlets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "outletCell", for: indexPath) as! OutletFeedCellCollectionViewCell
        let index = indexPath.row
        cell.outletName.text = outlets[index].outletName
        cell.outletCaption.text = outlets[index].outletCaption
        cell.deliveryFee.text = "KSH " + outlets[index].outletMilage!
        cell.outletBannerImage.sd_setImage(with: URL(string: outlets[index].outletBannerImage!), placeholderImage: UIImage(named: ""), options: [], completed: nil)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "categoryOutletSegue" {
            let vc = segue.destination as! OutletDetailViewController
            let outletSelected = sender as? OutletFeedCellCollectionViewCell
            
            vc._outletName =  outletSelected?.outletName.text!
            vc._outletCaption = outletSelected?.outletCaption.text!
            if let cell = sender as? OutletFeedCellCollectionViewCell {
                if let indexPath = outletCollectionView.indexPath(for: cell) {
                    vc._outletSlug = outlets[indexPath.item].outletSlug
                    vc.delivery_fee = outlets[indexPath.item].outletMilage
                }
            }

        }
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
