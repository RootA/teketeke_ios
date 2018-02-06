//
//  SearchNearestViewController.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 18/09/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces


class SearchNearestViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
    @IBOutlet weak var navSubview: UIView!
    
    @IBOutlet weak var googlePlacesBar: UISearchBar!
    
    @IBOutlet weak var navSearch: UIView!

     @IBOutlet weak var mapViewUI: GMSMapView!
 
    func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    var resultArray: [Any] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        let navBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 16, width: view.frame.width, height: 44))
        navBar.backgroundColor = UIColor.white
        self.view.addSubview(navBar);
        let navItem = UINavigationItem(title: "Search by Location");
        let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: nil, action: #selector(backButton));
        
        navItem.rightBarButtonItem = doneItem;
        navBar.setItems([navItem], animated: false);
        
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self as GMSAutocompleteResultsViewControllerDelegate?
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        let subView = UIView(frame: CGRect(x: 0, y: 64.0, width: view.frame.width, height: 45.0))
        
        subView.addSubview((searchController?.searchBar)!)
        subView.backgroundColor = UIColor.white
        view.addSubview(subView)
        
        
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false
        
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
        
        self.mapViewUI.delegate = self
        
        let camera = GMSCameraPosition.camera(withLatitude: -1.298694 , longitude: 36.798140, zoom: 12)
        //        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        //        mapViewUI = mapView
        self.mapViewUI.camera = camera
        self.mapViewUI.isMyLocationEnabled = true
        
        let currentLocation = CLLocationCoordinate2D(latitude: -1.298694, longitude: 36.798140)
        let marker = GMSMarker(position: currentLocation)
        //        marker.icon = UIImage(named: "")
        marker.map = mapViewUI
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// Handle the user's selection.
extension SearchNearestViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place.
        //check if user is logged in
        if UserDefaults.standard.value(forKey: "access_token") == nil {
            return
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
                                    let outlet_caption = data["caption"] as! String
                                    let outlet_slug = data["slug"] as! String
                                    let outlet_logo = data["logo"] as! String
                                    let outlet_desc = data["description"] as! String
                                    let outlet_banner = data["banner"] as! String
                                    
                                    let image_string = "\(ApiService.sharedInstance.image_url)\(outlet_banner)"
                                    outletsData.append(Outlet(outletName: outlet_name, outletCaption: outlet_caption, outletBannerImage: image_string, outletLogoImage: outlet_logo, outletMilage: outlet_name, outletDescription: outlet_desc, outletSlug: outlet_slug))
                                }
                            }
                            DispatchQueue.main.async {
                                //push content to a different screen board
//                                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                                let vc : MenuDetailViewController = storyboard.instantiateViewController(withIdentifier: "searchDetail") as! MenuDetailViewController
//                                vc.outlets = outletsData
//                                self.present(vc, animated: true, completion: nil)
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
