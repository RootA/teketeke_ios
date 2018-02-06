//
//  AccountViewController.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 14/09/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var profileScrollView: UIScrollView!
    
    @IBOutlet weak var accountinfoLabel: UILabel!
    @IBOutlet weak var firstname: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!

    
    
    @IBAction func saveAccountBtn(_ sender: Any) {
        let phone_number = phoneNumber?.text
        let email_address = emailAddress?.text
        
        let parameters = [
            "first_name": firstname?.text,
            "last_name" : lastName?.text,
            "email" : email_address,
            "phone_number" : phone_number
        ]
        
        profileUpdate(parameters: parameters)
    }
    
    func setupNavBar(){
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    func profileUpdate(parameters: Any){
        guard let profile_update_url = URL(string: "\(ApiService.sharedInstance.baseUrl)profile/edit") else { return }
        
        
        var request = URLRequest(url: profile_update_url)
        
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
                    //update the user defaults information
                    if UserDefaults.standard.value(forKey: "phone_number") as? String == self.phoneNumber.text || UserDefaults.standard.value(forKey: "email") as? String == self.emailAddress.text {
                        return
                    }else {
                        UserDefaults.standard.removeObject(forKey: "phone_number")
                        UserDefaults.standard.setValue(self.phoneNumber?.text, forKey: "phone_number")
                        UserDefaults.standard.removeObject(forKey: "email")
                        UserDefaults.standard.setValue(self.phoneNumber?.text, forKey: "email")
                        UserDefaults.standard.synchronize()
                        
                        self.emailAddress.reloadInputViews()
                        self.phoneNumber.reloadInputViews()
                    }
                    //perform this on a different thread
                    DispatchQueue.main.async {
                        let success_alert = UIAlertController(title: "Success", message: "Profile has successfully been updated", preferredStyle: .alert)
                        success_alert.addAction(UIAlertAction(title: "OK", style:.default, handler: nil))
                        self.present(success_alert, animated: true, completion: nil)
                    }
                }catch {
                    print(error)
                }
                
            }
            }.resume()
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure ?", message: "Press Ok to confirm logout", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style:.default, handler: { (action)  in self.handleLogout() }))
        alert.addAction(UIAlertAction(title: "Cancel", style:.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleLogout(){
        UserDefaults.standard.removeObject(forKey: "access_token")
        self.parent?.navigationController?.present(ViewController(), animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.value(forKey: "access_token") != nil {
            firstname.text = UserDefaults.standard.value(forKey: "first_name") as? String
            lastName.text = UserDefaults.standard.value(forKey: "last_name") as? String
            phoneNumber.text = UserDefaults.standard.value(forKey: "phone_number") as? String
            emailAddress.text = UserDefaults.standard.value(forKey: "email") as? String
            
        }else {
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let loginController : LoginViewController = storyboard.instantiateViewController(withIdentifier: "loginController") as! LoginViewController
            self.present(loginController, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupNavBar()
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
