//
//  CustomOrderCompleteViewController.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 02/10/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData


class CustomOrderCompleteViewController: UIViewController, CLLocationManagerDelegate, UIScrollViewDelegate  {
    var parameters: [CartData] = []
    
    var cartArray: [Cart] = []
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext //defines the core data context
    
    @IBOutlet weak var uiscroll: UIScrollView!
    @IBOutlet weak  var payersPhoneNumber: UITextField!
    @IBOutlet weak var receiversPhoneNumber: UITextField!
    @IBOutlet weak var note : UITextView!
    
    
    
    @IBAction func completeOrderButton(_ sender: Any) {
        if UserDefaults.standard.value(forKey: "access_token") != nil {
            queueOrder()
        }else {
            let success_alert = UIAlertController(title: "Success", message: "Login in to finish your order", preferredStyle: .alert)
            success_alert.addAction(UIAlertAction(title: "OK", style:.default, handler: { (action) in self.handleLogin() }))
            self.present(success_alert, animated: true, completion: nil)
        }
    }
    
    
    func handleLogin(){
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginController : LoginViewController = storyboard.instantiateViewController(withIdentifier: "loginController") as! LoginViewController
        self.present(loginController, animated: true, completion: nil)
    }
    
    
    func loadHome(){
        self.parent?.navigationController?.popToRootViewController(animated: true)
    }
    var locationManager = CLLocationManager()
    
    var lng: Double?
    var lat: Double?
    
    func queueOrder(){
        
        //get the users location
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        let locValue: CLLocationCoordinate2D = (locationManager.location?.coordinate)!
        lng = locValue.longitude
        lat = locValue.latitude
        
        
        var cartItems: [NSDictionary] = []
        
        let first_name = UserDefaults.standard.value(forKey: "first_name") as? String
        let last_name = UserDefaults.standard.value(forKey: "last_name") as? String
        let full_name = first_name! + " " + last_name!
        
        
        for cart_items in parameters {
            let cart_id = cart_items.cartId
            cartItems.append(["cart_id": cart_id as Any])
        }
        
        let order_details = [
            "payer_phone_number" : payersPhoneNumber?.text! as Any,
            "receiver_phone_number" : receiversPhoneNumber?.text! as Any,
            "receiver_name": full_name,
            "delivery": 200,
            "note" : note?.text! as Any,
            "lat" : lat as Any,
            "lng" : lng as Any,
            "cart_items": cartItems
            ] as NSDictionary

        postOrder(order: order_details)
        
    }
    
    func postOrder(order: Any){
        
        let order_url = URL(string: "\(ApiService.sharedInstance.baseUrl)complete_order")
        
        var request = URLRequest(url: order_url!)
        
        request.httpMethod = "POST"
            
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(UserDefaults.standard.value(forKey: "access_token")!)", forHTTPHeaderField: "Authorization")
        
        let jsonData = try? JSONSerialization.data(withJSONObject: order, options: .prettyPrinted)
        
        request.httpBody = jsonData
        
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print("ERROR FROM REQUEST")
                return
            }
            do {
                //convert to an array
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as AnyObject
                if let order_details = json["order"] as AnyObject? {
                    let orderID = order_details["id"] as? Int
                    
                    //update core data to reflect that checkout has been made
                    
                    let newCart = NSEntityDescription.insertNewObject(forEntityName: "Delivery", into: self.context)
                    
                    newCart.setValue(orderID, forKey: "order_id")
                    newCart.setValue(Int((self.receiversPhoneNumber?.text)!), forKey: "receivers_number") //save the phone_number of whomever is paying for the order
                    newCart.setValue(Int((self.payersPhoneNumber?.text)!), forKey: "payers_number") //save the phone_number of whomever is receiving the order
                    newCart.setValue(1, forKey: "checkout_status") //denotes successful checkout
                    newCart.setValue(0, forKey: "delivery_status") //denotes delivery not made yet
                    
                    do{
                        try self.context.save()

                    }catch{
                        let nserror = error as NSError
                        fatalError("Unresolved error \(nserror), \(nserror.userInfo)") //remove during production
                    }
                    
                }
                
                if let message = json ["message"]{
                    print(message as Any)
                    let success_alert = UIAlertController(title: "Success", message: message as? String, preferredStyle: .alert)
                    success_alert.addAction(UIAlertAction(title: "OK", style:.default, handler: { (action) in self.loadHome() }))
                    self.present(success_alert, animated: true, completion: nil)
                }
                
            } catch {
                print(error)
                return
            }
            }.resume()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.init(red: 255/255, green: 0/255, blue: 128/255, alpha: 1)
        
        receiversPhoneNumber?.text = UserDefaults.standard.value(forKey: "phone_number") as? String
        payersPhoneNumber?.text = UserDefaults.standard.value(forKey: "phone_number") as? String
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self 
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            let locValue: CLLocationCoordinate2D = (manager.location?.coordinate)!
            lng = locValue.longitude
            lat = locValue.latitude
            

        }//if authorized
    }//locationManager func declaration

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
