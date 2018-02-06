//
//  ViewController.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 12/09/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate {
 
    @IBOutlet weak var mainTableView: UITableView!
    
    @IBOutlet weak var categoryUICollectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewLabel: UICollectionViewCell!
    
     var CategoryArray: [Category] = []
    
    var outlets = [Outlet]()
    var selectedoutlet = Outlet.self
    let cellId = "outletdatacell"
    
    var imageURLString : String?
    let activityIndicatorCustom = ActivityIndicator()
    
    var outlet_Name: String?
    var outlet_Slug: String?
    var outlet_Caption: String?
    var cartArray:[Cart] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let locationManager = CLLocationManager()
    
    var global_lat : Double?
    var global_lng : Double?
    
    var distance_to_price: String?
    
    func fetchOutlets(lat: Double, lng: Double)
    {
        activityIndicatorCustom.show()
        guard let search_url = URL(string: "\(ApiService.sharedInstance.baseUrl)search/nearest/coordinates") else { return }
        
        let parameters = [
            "lat" : lat,
            "lng" : lng
        ]
        
        
        var request = URLRequest(url: search_url)
        
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response,error) in
            if error != nil {
                print(error.debugDescription)
            }
            
            if let data = data {
                
                let options = JSONSerialization.ReadingOptions.mutableContainers
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: options) as? [String : AnyObject]
                    
                    var outlets = [Outlet]()
                                        
                    //loop through the return data, convert to a dictinary of array objects
                    if let array = json {
//                        let image_url = json["outlet_image_url"] as! String
                        let image_url = ApiService.sharedInstance.image_url
                        if let fbData = array["data"] as? [[String : AnyObject]] {
                            //fetch the outlets
                            for outlet in fbData {
                                if let outlet_info = outlet["outlets"] as? [AnyObject] {
                                    for data in outlet_info {
                                        let _ = data["id"] as! NSNumber
                                        let outletName = data["name"] as! String
                                        let outletCap = data["caption"] as? String ?? " "
                                        let thumbnailImageName = data["banner"] as? String ?? ""
                                        let outletSlug = data["slug"] as! String
                                        let outletLogo = data["logo"] as? String ?? " "
                                        let outletDesc = data["description"] as? String ?? " "
                                        let outlet_lat = data["lat"] as! String
                                        let outlet_lng = data["lng"] as! String
                                        
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
                                        
                                        let image_url_string = image_url + thumbnailImageName
                                        outlets.append(Outlet(outletName:outletName, outletCaption: outletCap, outletBannerImage: image_url_string, outletLogoImage: outletLogo, outletMilage: self.distance_to_price!, outletDescription: outletDesc, outletSlug: outletSlug))
                                    }
                                    
                                }
                            }
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.activityIndicatorCustom.hide()
                        self.outlets = outlets
                        self.mainTableView.reloadData()
                    }
                }catch {
                    print(error)
                }
            }
            }.resume()
        
//        ApiService.sharedInstance.fetchOutlets { (outlets: [Outlet]) in
//            self.outlets = outlets
//            self.mainTableView.reloadData()
//        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        //check for internet connection
        if Reachability.isConnectedToNetwork(){
            fecthCategories()
        }else {
            activityIndicatorCustom.hide()
            //Alert the user of a no internet connection
            let success_alert = UIAlertController(title: "Internet Connection", message: "You Appear To have no internet Connection at the moment. Connect to a WiFi Network, or turn on Cellular Data from Settings", preferredStyle: .alert)
            success_alert.addAction(UIAlertAction(title: "OK", style:.default, handler: nil))
            self.present(success_alert, animated: true, completion: nil)
        }
    }
    
    func fecthCategories(){
        CategoryArray = []
        
        let get_categories_url = URL(string: "\(ApiService.sharedInstance.baseUrl)outlets/types")
        activityIndicatorCustom.show()
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
                            let caption = eachCategory["description"] as! String
                            let slug = eachCategory["slug"] as! String
                            
                            self.CategoryArray.append(Category(categoryName: category, categoryDesc: caption, categorySlug: slug))
                        }
                        DispatchQueue.main.async {
                            self.categoryUICollectionView?.reloadData()
                            self.activityIndicatorCustom.hide()
                        }
                    }
                }
            } catch(let parseError){
                print("There was an error parsing the JSON: \"\(parseError.localizedDescription)\"")
            }
            }.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(activityIndicatorCustom)
        
        //check if the user has updated loation before and user those coords
        getUserCoords()
        fetchCartItems()
        categoryUICollectionView.showsHorizontalScrollIndicator = true
        if global_lat != nil && global_lng != nil {
            fetchOutlets(lat: global_lat!, lng: global_lng!)
        } else {
            //set the delegate to be the one current
            isAuthorizedtoGetUserLocation()
            
            if CLLocationManager.locationServicesEnabled() {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
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
            
            global_lat = locValue.latitude
            global_lng = locValue.longitude
            
            fetchOutlets(lat: locValue.latitude, lng: locValue.longitude)
        }
    }
    
    func getUserCoords(){
        do{
            let results = try self.context.fetch(Location.fetchRequest())
            
            for result in results as! [NSManagedObject] {
                global_lat =  result.value(forKey: "lat")! as? Double
                global_lng = result.value(forKey: "lng")! as? Double
            }
        }catch{}
    }
    
    func fetchCartItems(){
        do{
            cartArray = try context.fetch(Cart.fetchRequest())
            tabBarController?.tabBar.items?[2].badgeValue = String(cartArray.count)
        }
        catch{
            print(error)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (outlets.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let outletCell = mainTableView.dequeueReusableCell(withIdentifier: "outletsCell", for: indexPath) as! HomeviewTableViewCell
        
         let index: Int = indexPath.row
        
        outletCell.outletName.text = outlets[index].outletName
        outletCell.outletDesc.text = outlets[index].outletCaption
        outletCell.deliveryCost.text = "KSH " + outlets[index].outletMilage!
        outletCell.outletThumbnail.sd_setImage(with: URL(string: outlets[index].outletBannerImage!), placeholderImage: UIImage(named: "iu-3"))
        return outletCell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "outletdetail") {
            let indexPath = self.mainTableView.indexPathForSelectedRow
            let cell = mainTableView.cellForRow(at: indexPath!) as! HomeviewTableViewCell
            
            
            let vc = segue.destination as! OutletDetailViewController
            vc._outletName = cell.outletName.text
            vc._outletCaption = cell.outletDesc.text
            vc._outletSlug = outlets[(indexPath?.row)!].outletSlug
            vc.delivery_fee = outlets[(indexPath?.row)!].outletMilage
        }
    }

    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = targetContentOffset.pointee.x / view.frame.width
        
        let indexPath = NSIndexPath(item: Int(index), section: 0)
     
        categoryUICollectionView.selectItem(at: indexPath as IndexPath, animated: true, scrollPosition: [])
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width / CGFloat(CategoryArray.count), height: view.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CategoryArray.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let categoryCell = categoryUICollectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! HomeCategoryNavCollectionViewCell
        categoryCell.homeCategoryLabel?.text = CategoryArray[indexPath.row].categoryName
        return categoryCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let categorySelected = CategoryArray[indexPath.item]
        
        navigationItem.title = categorySelected.categoryName!
        getCategoryData(slug: (categorySelected.categorySlug)!)
    }
    
    func getCategoryData(slug: String) {
        self.activityIndicatorCustom.show()
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
                    
                    if (outlets_info.count == 0){
                        //alter the maintable view to show the user that no data has been found
                        let success_alert = UIAlertController(title: "No Outlets Found", message: "Apologies No Outlet From \(self.navigationItem.title!) is Currently Listed at the Moment", preferredStyle: .alert)
                        success_alert.addAction(UIAlertAction(title: "OK", style:.default, handler: nil))
                        self.present(success_alert, animated: true, completion: nil)
                        
                        DispatchQueue.main.async {
                            self.activityIndicatorCustom.hide()
                            self.mainTableView.reloadData()
                        }
                    }else {
                        // show data that has been fetched
                        
                        for data in outlets_info {
                            let tdata = data as? [String : AnyObject]
                            let outlet_name = tdata?["name"] as! String
                            let _ = tdata?["coordinates"] as? String ?? " "
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
                                    let price = (diff_in_distance/1000) * 30
                                    self.distance_to_price = "\(price + ApiService.sharedInstance.delivery_fee_for_4km)"                                    
                            }
                            
                            let image_string = image_url+outlet_banner
                            //append the data to the outlets array
                            self.outlets.append(Outlet(outletName: outlet_name, outletCaption: outlet_caption, outletBannerImage: image_string, outletLogoImage: outlet_logo, outletMilage: self.distance_to_price!, outletDescription: outlet_desc, outletSlug: outlet_slug))
                        }
                        //
                        DispatchQueue.main.async {
                            self.mainTableView?.reloadData()
                            self.activityIndicatorCustom.hide()
                        }
                    }
                }
            } catch(let parseError){
                print("There was an error parsing the JSON: \"\(parseError.localizedDescription)\"")
            }
            }.resume()
    }
}



