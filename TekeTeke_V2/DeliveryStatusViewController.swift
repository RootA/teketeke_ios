//
//  DeliveryStatusViewController.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 17/09/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData


class DeliveryStatusViewController: UIViewController, CLLocationManagerDelegate  {
    @IBOutlet var deliveryMapView: MKMapView!
    
    @IBOutlet weak var orderMessage: UILabel!
    
    @IBOutlet weak var orderSubMessage: UILabel!
    
    @IBOutlet weak var orderTimer: UILabel!
    @IBOutlet weak var orderMinHand: UILabel!
    
    var orders: [NSManagedObject] = []
    
    var orderID: Int?
    var order_status_message: String = ""
    var order_status_desc: String = ""
    var order_delivery_cost: Int = 0
    
    var delivery_id: Int = 1
    
    var lat: String = "-1.3209804"
    var lng: String = "36.7996708"
    
    let activityIndicatorCustom = ActivityIndicator()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    let manager = CLLocationManager()

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //get the most resent location of the user
        _ = locations[0]
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        
        let ridersLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(Double(lat)!, Double(lng)!)
        
        let region: MKCoordinateRegion = MKCoordinateRegionMake(ridersLocation, span)
        
        deliveryMapView.setRegion(region, animated: true)
        
        
        self.deliveryMapView.showsUserLocation = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.init(red: 255/255, green: 0/255, blue: 128/255, alpha: 1)

        // Do any additional setup after loading the view.
        getCoreData()
        
        self.view.addSubview(activityIndicatorCustom)
        
        //set the delegate to be the one current
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest //get the most accurate location of the user
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func deliveryDetails(){
        //query the database for the order
        activityIndicatorCustom.show()
        guard let url = URL(string: "\(ApiService.sharedInstance.baseUrl)get/delivery/\(orderID!)") else {return}
        
        var request = URLRequest(url: url)
        
        
        //append the request headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let access_token = UserDefaults.standard.value(forKey: "access_token") as! String
        request.addValue("Bearer \(access_token)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        
        session.dataTask(with: request) { (data, response, error) in
            //make the request to the teketeke server
            if error != nil {
                print("ERROR FROM REQUEST")
                return
            }
            
            if let content = data {
                
                do {
                    //Array
                    let jsonData = try JSONSerialization.jsonObject(with: content, options: .mutableContainers) as AnyObject
                    let returnData = jsonData["delivery"] as? NSDictionary
                    if returnData != nil {
                        if let delivery = jsonData["delivery"] as? NSDictionary {
                            
                            if let status = delivery["status"] as? NSDictionary {
                                self.order_status_message  = (status["name"] as? String)!
                                self.order_status_desc  = (status["description"] as? String)!
                            }
                            
                            if let devlivery_data = delivery["order"] as? NSDictionary {
                                self.order_delivery_cost = (devlivery_data["delivery_cost"] as? Int)!
                                self.lng = (devlivery_data["lng"] as? String)!
                                self.lat = (devlivery_data["lat"] as? String)!
                            }
                            DispatchQueue.main.async {
                                self.orderMessage?.text = self.order_status_message
                                self.orderTimer?.text = String(self.order_delivery_cost)
                                self.orderSubMessage?.text = self.order_status_desc
                                
                                self.activityIndicatorCustom.hide()
                            }
                        }
                    }else{
                        //alert about order is waiting
                        DispatchQueue.main.async {
                            self.activityIndicatorCustom.hide()
                        }
                        let success_alert = UIAlertController(title: "Waiting", message: "We are working to get your order to a rider as soon as possible", preferredStyle: .alert)
                        success_alert.addAction(UIAlertAction(title: "OK", style:.default, handler: { (action) in self.loadHome()}))
                        self.present(success_alert, animated: true, completion: nil)
                    }
                } catch{
                    print(error)
                }
            }
            }.resume()
    }
    
    func loadHome(){
         navigationController?.popViewController(animated: true)
    }
    
    
    func getCoreData(){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Delivery")
        do{
            let result = try context.fetch(fetchRequest) as! [NSManagedObject]
            if result.count != 0 {
                for managedObject in result {
                    if let order_id = managedObject.value(forKey: "order_id")
                    {
                        
                        if order_id as? Int != nil {
                            self.orderID = order_id as? Int
                            self.deliveryDetails()
                            self.getRidersLocation(deliveryid: self.delivery_id)
                        }else{
                            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc : NoOrdersViewController = storyboard.instantiateViewController(withIdentifier: "no_order") as! NoOrdersViewController
                            self.present(vc, animated: true, completion: nil)
                        }
                        
                    }
                }
            } else {
                //alert the user that they have no deliveries present
                let success_alert = UIAlertController(title: "Delivery Alert", message: "You appear to have no delivering pending at the moment ... Be sure to place an order soon", preferredStyle: .alert)
                success_alert.addAction(UIAlertAction(title: "OK", style:.default, handler: { (action) in self.loadBackHome() }))
                self.present(success_alert, animated: true, completion: nil)
            }
        } catch{
            print("error")
        }
    }
    
    func loadBackHome(){
        navigationController?.popViewController(animated: true)
    }
    
    func getRidersLocation(deliveryid: Int) {
//        activityIndicatorCustom.show()
        guard let riders_position_url = URL(string: "\(ApiService.sharedInstance.baseUrl)delivery/get_position/\(deliveryid)") else { return }
        var request = URLRequest(url: riders_position_url)
        
        
        //append the request headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let access_token = UserDefaults.standard.value(forKey: "access_token") as! String
        request.addValue("Bearer \(access_token)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        
        session.dataTask(with: request) { (data, response, error) in
            //make the request to the teketeke server
            if error != nil {
                print("ERROR FROM REQUEST")
                return
            }
            
            if let content = data {
                
                do {
                    //Array
                    let jsonData = try JSONSerialization.jsonObject(with: content, options: .mutableContainers) as AnyObject
                    if let position = jsonData["position"] as? NSDictionary {
                        
                        self.lat = position["lat"] as! String
                        self.lng = position["lng"] as! String
                        
                        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
                        
                        let ridersLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(Double(self.lat)!, Double(self.lng)!)
                        
                        let region: MKCoordinateRegion = MKCoordinateRegionMake(ridersLocation, span)
                        
                        self.deliveryMapView.setRegion(region, animated: true)
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = ridersLocation
                        annotation.title = "We Are here ..."
                        self.deliveryMapView.addAnnotation(annotation)
                        self.deliveryMapView.showsUserLocation = true
                        
//                        self.activityIndicatorCustom.hide()
                    }
                } catch{
                    print(error)
                }
            }
            }.resume()
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
