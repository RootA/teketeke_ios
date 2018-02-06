//
//  CustomOrderViewController.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 13/09/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit

class CustomOrderViewController: UIViewController, UIScrollViewDelegate {
    
    let base_url = ApiService.sharedInstance.baseUrl

    var outletId: Int?
    @IBOutlet weak var productName: UITextField!
    @IBOutlet weak var productQty: UITextField!
    @IBOutlet weak var orderDescription: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBAction func confirmOrderButton(_ sender: Any) {
        //handles data
        //check if the outletID has been provided
        if orderDescription?.text == "" {
            return
        }
        
        if outletId != nil {
            let parameters = [
                "outlet_id" : outletId!,
                "title" : productName?.text! as Any,
                "quantity" : productQty?.text! as Any ,
                "details" : orderDescription?.text! as Any
                ] as [String : Any]
            print(parameters)
            //use the order anything post url that requires an order id
            orderAnythingWithOutletID(parameters: parameters)
        }else{
            
            let parameters = [
                "details" : orderDescription?.text! as Any,
                "title" : productName?.text! as Any,
                "quantity" : productQty?.text! as Any
                ] as [String : Any]
            
            //use the order any post url
            orderAnythingWithoutOutletID(parameters: parameters)
        }
    }
    

    
    func orderAnythingWithOutletID(parameters: Any){
        
        guard let post_url = URL(string: "\(base_url)order/outlet/anything") else { return }
        
        var request = URLRequest(url: post_url)
        
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(UserDefaults.standard.value(forKey: "access_token")!)", forHTTPHeaderField: "Authorization")
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response,error) in
            if error != nil {
                print(error.debugDescription)
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                    
                    //perform this on a different thread
                    DispatchQueue.main.async {
                        let success_alert = UIAlertController(title: "Success", message: "You order has been filed. Details will be relayed to you as soon as possible", preferredStyle: .alert)
                        success_alert.addAction(UIAlertAction(title: "OK", style:.default, handler: nil))
                        self.present(success_alert, animated: true, completion: nil)
                    }
                }catch {
                    print(error)
                }
                
            }
            }.resume()
    }
    
    func orderAnythingWithoutOutletID(parameters: Any){
        
        guard let post_url = URL(string: "\(base_url)order/anything") else { return }
        
        var request = URLRequest(url: post_url)
        
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(UserDefaults.standard.value(forKey: "access_token")!)", forHTTPHeaderField: "Authorization")
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response,error) in
            if error != nil {
                print(error.debugDescription)
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                    
                    //perform this on a different thread
                    DispatchQueue.main.async {
                        let success_alert = UIAlertController(title: "Success", message: "You order has been filed. Details will be relayed to you as soon as possible", preferredStyle: .alert)
                        success_alert.addAction(UIAlertAction(title: "OK", style:.default, handler: nil))
                        self.present(success_alert, animated: true, completion: nil)
                    }
                }catch {
                    print(error)
                }
                
            }
            }.resume()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
