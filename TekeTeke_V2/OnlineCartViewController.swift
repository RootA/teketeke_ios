//
//  OnlineCartViewController.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 17/09/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit

class OnlineCartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
 
    var cartData: [CartData] = []
    @IBOutlet weak var mainTableView: UITableView!
    let activityIndicatorCustom = ActivityIndicator()
    
    @IBAction func checkoutBtn(_ sender: Any){
        if UserDefaults.standard.value(forKey: "access_token") == nil {
            handleLogin()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if UserDefaults.standard.value(forKey: "access_token") == nil {
            handleLogin()
        }else {
            if segue.identifier == "customOrderSegue" {
                let vc = segue.destination as! CustomOrderCompleteViewController
                vc.parameters = cartData
            }
        }
    }
    
    @IBOutlet weak var checkoutButton: UIButton!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = UIColor.init(red: 255/255, green: 0/255, blue: 128/255, alpha: 1)
        self.view.addSubview(activityIndicatorCustom)
        
        // make and API request to get cart details
        if UserDefaults.standard.value(forKey: "access_token") != nil {
            getCartData()
        }else {
            let alert = UIAlertController(title: "Error", message: "Please Login to continue", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style:.default, handler: { (action) in self.handleLogin() }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func handleLogin(){
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginController : LoginViewController = storyboard.instantiateViewController(withIdentifier: "loginController") as! LoginViewController
        self.present(loginController, animated: true, completion: nil)
    }
    
    func getCartData() {
        activityIndicatorCustom.show()
        cartData = []
        //query the database for the order
        guard let url = URL(string: "\(ApiService.sharedInstance.baseUrl)carts/all") else {return}
        
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
                    if let results = jsonData["data"] as! NSArray? {
                        if results.count != 0 {
                            for cartInfo in results {
                                let tdata = cartInfo as? [String : AnyObject]
                                let productId = tdata?["product_id"] as? Int ?? 0
                                let outletId = tdata?["outlet_id"] as? Int ?? 0
                                let qty = tdata?["quantity"] as! Int
                                let tax = tdata?["tax"] as! Int
                                let customName = tdata?["custom_name"] as! String
                                let itemPrice = tdata?["price"] as! Int
                                let subTtl = tdata?["subtotal"] as! Int
                                let cartID = tdata?["id"] as! Int
                                
                                self.cartData.append(CartData(product_id: productId, outlet_id: outletId , quantity: qty, subtotal: subTtl, commission_tax: tax, customName: customName, itemPrice: itemPrice, cartId: cartID))
                            }
                            DispatchQueue.main.async {
                                self.activityIndicatorCustom.hide()
                                self.mainTableView.reloadData()
                            }
                        }else {
                            DispatchQueue.main.async {
                                self.activityIndicatorCustom.hide()
                            }
                            let success_alert = UIAlertController(title: "Cart is Empty", message: "Your cart Appears to be empty", preferredStyle: .alert)
                            success_alert.addAction(UIAlertAction(title: "OK", style:.default, handler: { (action) in self.loadHome() }))
                            self.present(success_alert, animated: true, completion: nil)
                        }
                    }
                }
                catch{
                    print(error)
                }
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
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let onlinecartcell = mainTableView.dequeueReusableCell(withIdentifier: "onlineCartCell", for: indexPath) as! OnlineCartTableViewCell
        
        let index: Int = indexPath.row
        //category name
        onlinecartcell.customName?.text = self.cartData[index].customName
        onlinecartcell.itemPrice?.text = "ksh \(self.cartData[index].itemPrice!)"
        onlinecartcell.orderQty?.text = "x \(self.cartData[index].quantity)"
        onlinecartcell.subTotal?.text = "KSH \(self.cartData[index].subtotal)"
        return onlinecartcell
    }
    

}
