//
//  PromoCodeViewController.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 13/11/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit

class PromoCodeViewController: UIViewController {

    
    @IBOutlet weak var promoCode: UITextField!
    
    @IBAction func postCode(){
        if promoCode.text! != "" {
            self.postPromoCode(parameters: promoCode.text!)
        }else {
            //perform an alert message
            let success_alert = UIAlertController(title: "Error", message: "Enter a Code", preferredStyle: .alert)
            success_alert.addAction(UIAlertAction(title: "OK", style:.default, handler: nil))
            self.present(success_alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func closeUI(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //hide keyboard when not in use
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    func postPromoCode(parameters: Any){
        let new_parameters = [
            "code" : parameters
        ]
        guard let promoCodeUrl = URL(string: "\(ApiService.sharedInstance.baseUrl)codes/confirm") else { return }
        
        var request = URLRequest(url: promoCodeUrl)
        
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(UserDefaults.standard.value(forKey: "access_token")!)", forHTTPHeaderField: "Authorization")
        
        let jsonData = try? JSONSerialization.data(withJSONObject: new_parameters, options: .prettyPrinted)
        
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
                
                if let response = json["message"] as AnyObject? {
                    let data = response as! String
                    
                    //perform an alert message
                    let success_alert = UIAlertController(title: "Success", message: data, preferredStyle: .alert)
                    success_alert.addAction(UIAlertAction(title: "OK", style:.default, handler: nil))
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
