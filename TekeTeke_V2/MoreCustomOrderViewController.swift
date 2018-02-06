//
//  MoreCustomOrderViewController.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 17/09/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit

class MoreCustomOrderViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var moreLabel: UILabel!
    @IBOutlet weak var productName: UITextField!
    @IBOutlet weak var productQty: UITextField!
    @IBOutlet weak var orderNote: UITextView!
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func confirmOrderBtn(_ sender: Any) {
        
        if (productName?.text)! == "" && (productQty?.text)! == "" && (orderNote?.text)! == "" {
            return
        }else {
            //Confirm the parameters
            let parameters = [
                "itemname" : productName?.text! as Any,
                "itemqty" : productQty?.text! as Any,
                "details" : orderNote?.text! as Any
                ] as [String : Any]
            
            //use the order any post url
            orderAnythingWithoutOutletID(parameters: parameters)
            
        }
    }
    
  

    
    func orderAnythingWithoutOutletID(parameters: Any){
        
        guard let post_url = URL(string: "\(ApiService.sharedInstance.baseUrl)order/anything") else { return }
        
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
        self.hideKeyboardWhenTappedAround() 
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
