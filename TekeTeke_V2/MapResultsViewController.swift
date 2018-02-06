//
//  MapResultsViewController.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 24/09/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit
import CoreLocation

class MapResultsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate {
    
    var outlets: [Outlet] = []
    var CategoryArray: [Category] = []
    
    @IBAction func cancelBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var outletCollectionView: UICollectionView!
    
    @IBOutlet weak var categoryCollectionView: UICollectionView!
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        
        outletCollectionView.dataSource = self
        outletCollectionView.delegate = self
        
        //set the delegate to be the one current
        isAuthorizedtoGetUserLocation()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fecthCategories()
    }
    
    func fecthCategories(){
        CategoryArray = []
        
        let get_categories_url = URL(string: "\(ApiService.sharedInstance.baseUrl)outlets/types")
        
        URLSession.shared.dataTask(with: get_categories_url!) { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            let options = JSONSerialization.ReadingOptions.mutableContainers
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: options) as? [String : AnyObject]
                
                if let array = json{
                    if let fbData = array["data"] as? [[String : AnyObject]] {
                        //fetch the categories
                        for eachFetchedCategory in fbData {
                            let eachCategory = eachFetchedCategory as [String: Any]
                            let category = eachCategory["name"] as! String
                            let caption = eachCategory["description"] as? String ?? " "
                            let slug = eachCategory["slug"] as! String
                            
                            self.CategoryArray.append(Category(categoryName: category, categoryDesc: caption, categorySlug: slug))
                        }
                        DispatchQueue.main.async {
                            self.categoryCollectionView?.reloadData()
                        }
                    }
                }
            } catch(let parseError){
                print("There was an error parsing the JSON: \"\(parseError.localizedDescription)\"")
            }
            }.resume()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if collectionView == categoryCollectionView {
           return CategoryArray.count
        }else {
             return outlets.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == outletCollectionView {
            let cell = outletCollectionView.dequeueReusableCell(withReuseIdentifier: "map_feed", for: indexPath) as! MapsCollectionViewCell
            
            cell.outletName.text = outlets[indexPath.row].outletName
            cell.outletcaption.text = outlets[indexPath.row].outletCaption
            cell.delivery_fee.text = "KSH " + outlets[indexPath.row].outletMilage!
            cell.outletBannerImage.sd_setImage(with: URL(string: outlets[indexPath.row].outletBannerImage!), placeholderImage: UIImage(named: ""), options: [.avoidAutoSetImage , .progressiveDownload])
            return cell
        }else {
            let categoryCell = categoryCollectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! HomeCategoryNavCollectionViewCell
            categoryCell.homeCategoryLabel?.text = CategoryArray[indexPath.row].categoryName
            return categoryCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = CategoryArray[indexPath.item]
        if collectionView == categoryCollectionView {
            navigationItem.title = index.categoryName!
            //pass the category slug
            getCategoryData(slug: (index.categorySlug)!)
        }
    }
    
    func getCategoryData(slug: String) {
        outlets = []
        let get_categories_url = URL(string: "\(ApiService.sharedInstance.baseUrl)outlets/type/\(slug)")
        
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
                    for data in outlets_info {
                        let tdata = data as? [String : AnyObject]
                        let outlet_name = tdata?["name"] as! String
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
                            if diff_in_distance > ApiService.sharedInstance.basic_delivery_km {
                                let price = diff_in_distance/1000 * 30
                                self.distance_to_price = "\(price + ApiService.sharedInstance.delivery_fee_for_4km)"
                            }
                        }
                        
                        let image_string = image_url+outlet_banner
                        //append the data to the outlets array
                        self.outlets.append(Outlet(outletName: outlet_name, outletCaption: outlet_caption, outletBannerImage: image_string, outletLogoImage: outlet_logo, outletMilage: self.distance_to_price!, outletDescription: outlet_desc, outletSlug: outlet_slug))
                    }
                    //
                    DispatchQueue.main.async {
                        self.outletCollectionView?.reloadData()
                    }
                    
                }
            } catch(let parseError){
                print("There was an error parsing the JSON: \"\(parseError.localizedDescription)\"")
            }
            }.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapsOutletSegue" {
            let vc = segue.destination as! OutletDetailViewController
            let outletSelected = sender as? MapsCollectionViewCell
            
            vc._outletName =  outletSelected?.outletName.text!
            vc._outletCaption = outletSelected?.outletcaption.text!
            if let cell = sender as? MapsCollectionViewCell {
                if let indexPath = outletCollectionView.indexPath(for: cell) {
                    vc._outletSlug = outlets[indexPath.item].outletSlug
                }
            }
            
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
