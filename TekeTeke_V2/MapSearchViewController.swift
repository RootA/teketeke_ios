//
//  MapSearchViewController.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 19/09/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces


class MapSearchViewController: UIViewController, UISearchBarDelegate, GMSMapViewDelegate, CLLocationManagerDelegate {

    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
    var resultArray: [Any] = []

    @IBOutlet weak var MapUIView: GMSMapView!
//    @IBOutlet weak var locationSearch: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = UIColor.init(red: 255/255, green: 0/255, blue: 128/255, alpha: 1)

        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self as GMSAutocompleteResultsViewControllerDelegate?
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        let subView = UIView(frame: CGRect(x: 0, y: 0.0, width: view.frame.width, height: 45.0))
        
        subView.addSubview((searchController?.searchBar)!)
        subView.backgroundColor = UIColor.white
        view.addSubview(subView)
        
        searchController?.searchBar.sizeToFit()
        searchController?.searchBar.barTintColor = UIColor.white
        searchController?.searchBar.placeholder = "Enter a Location"
        searchController?.hidesNavigationBarDuringPresentation = false
        
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
        
        self.MapUIView.delegate = self
        
        let camera = GMSCameraPosition.camera(withLatitude: -1.298694 , longitude: 36.798140, zoom: 12)
        //        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        //        mapViewUI = mapView
        self.MapUIView.camera = camera
        self.MapUIView.isMyLocationEnabled = true
        
        let currentLocation = CLLocationCoordinate2D(latitude: -1.298694, longitude: 36.798140)
        let marker = GMSMarker(position: currentLocation)
        //        marker.icon = UIImage(named: "")
        marker.map = MapUIView
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


// Handle the user's selection.
extension MapSearchViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place.
        //check if user is logged in
        if UserDefaults.standard.value(forKey: "access_token") == nil {
            
            let alert = UIAlertController(title: "Warning", message: "Please login to continue", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style:.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else{
            getNearestPlaces(selectedPlace: place.name)
        }
    }
    
    func getNearestPlaces(selectedPlace: Any){
        //make a post request with the data
        
        let get_url = URL(string: "\(ApiService.sharedInstance.baseUrl)search/nearest")
        var request = URLRequest(url: get_url!)
        request.httpMethod = "POST"
        
        //append the request headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(UserDefaults.standard.value(forKey: "access_token")!)", forHTTPHeaderField: "Authorization")
        
        let jsonData = try? JSONSerialization.data(withJSONObject: ["location":selectedPlace], options: .prettyPrinted)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            //make the request to the teketeke server
            if error != nil {
                print("ERROR FROM REQUEST")
                return
            }
            let options = JSONSerialization.ReadingOptions.mutableContainers
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: options) as? [String : AnyObject]
                
                if let jsonresponse = json?["message"] {
                    //perfom an alert message
                    let alert = UIAlertController(title: ";( Error ", message: jsonresponse as? String, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style:.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                
                var outletsData: [Outlet] = []
                
                if let array = json {
                    if let fbData = array["data"] as? [[String : AnyObject]] {
                        //fetch all categories
                        for data in fbData {
                            if let Categories = data["outlet_category"] as AnyObject? {
                                print(Categories["name"])
                            }
                            
                            
                            if let outlet_info = data["outlets"] as? [AnyObject] {
                                for data in outlet_info {
                                    let outlet_name = data["name"] as! String
                                    let outlet_caption = data["caption"] as? String ?? " "
                                    let outlet_slug = data["slug"] as? String ?? " "
                                    let outlet_logo = data["logo"] as? String ?? " "
                                    let outlet_desc = data["description"] as? String ?? " "
                                    let outlet_banner = data["banner"] as? String ?? " "
                                    
                                    let image_string = "\(ApiService.sharedInstance.oauth_url)dummy/\(outlet_banner)"
                                    outletsData.append(Outlet(outletName: outlet_name, outletCaption: outlet_caption, outletBannerImage: image_string, outletLogoImage: outlet_logo, outletMilage: outlet_name, outletDescription: outlet_desc, outletSlug: outlet_slug))
                                }
                            }
                            DispatchQueue.main.async {
                                //push content to a different screen board
                            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                
                            let vc : MapResultsViewController = storyboard.instantiateViewController(withIdentifier: "map_feed_collection") as! MapResultsViewController
                            vc.outlets = outletsData
                                print(outletsData)
                            self.present(vc, animated: true, completion: nil)
                            }
                        }
                        
                    }
                }
                
                
                
            } catch (let parseError){
                print("There was an error parsing the JSON: \"\(parseError.localizedDescription)\"")
            }
            }.resume()
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
