//
//  LoginViewController.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 14/09/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit
import FacebookLogin

class LoginViewController: UIViewController {

     var dict : [String : AnyObject]!
    
    @IBAction func cancelBtn(_ sender: Any) {
        let vc : AnyObject! = self.storyboard!.instantiateViewController(withIdentifier: "homeview")
        self.show(vc as! UIViewController, sender: vc)
    }
    
    @IBOutlet weak var orSeparator: UILabel!
    @IBOutlet weak var forgotMyPassword: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let activityIndicatorCustom = ActivityIndicator()

    
    @IBAction func fbLogin(_ sender: Any) {
        let loginManageer = LoginManager()
        loginManageer.logIn(readPermissions : [.publicProfile, .email], viewController: self) {
            result in
            
            switch result {
            case .failed(let error):
                print(error)
                break
            case .cancelled:
                print("Login Canceled")
                break
            case .success( _, _ ,let userInfo):
                //save the data to core data
                UserDefaults.standard.setValue(userInfo.authenticationToken, forKey: "access_token")
                break
                
            }
        }
    }
    
    
    @IBAction func loginButton(_ sender: Any) {
        
        
        let username = emailTextField.text
        let password = passwordTextField.text
        
        if (username == "" || password == "") { return }
        
        doLogin(username: username!, password: password!)
    }
    
    
    
    func doLogin(username: String, password: String){
//        activityIndicatorCustom.show()
        let parameters = [
            "username": username,
            "password": password,
            "client_id": "2",
            "grant_type": "password",
            "scope": "*",
            "client_secret": "xCMcfHWcZxR5zp6kYydQAE9K2kbYE9wbkbIwxENH"
        ]
        
        
        guard let url = URL(string: "\(ApiService.sharedInstance.oauth_url)oauth/token") else { return }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print("ERROR FROM REQUEST")
                return
            }
            do {
                //convert to an array
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as AnyObject
                                
                //set the access-token to work with the session
                if let session_key = json["access_token"] as? String  {
                    UserDefaults.standard.setValue(session_key, forKey: "access_token")
                    UserDefaults.standard.synchronize()
                    
                    //perform this on a different thread
                    DispatchQueue.main.async {
                        self.loginDone()
//                        self.activityIndicatorCustom.hide()
                    }
                }
//
                if let errorOccured = json["message"] as? String {
                    //alert error while signin
                    DispatchQueue.main.async {
                        let success_alert = UIAlertController(title: "Error", message: errorOccured, preferredStyle: .alert)
                        success_alert.addAction(UIAlertAction(title: "OK", style:.default, handler: nil))
                        self.present(success_alert, animated: true, completion: nil)
                    }
                }
       
            }catch {
                return
            }
            }.resume()
    }
    
    func loginDone(){
        getUserDetails()
        let vc : AnyObject! = self.storyboard!.instantiateViewController(withIdentifier: "homeview")
        self.show(vc as! UIViewController, sender: vc)
    }
    
    func loginToDo(){
        emailTextField.isEnabled = true
        passwordTextField.isEnabled = true
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.addSubview(activityIndicatorCustom)
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
    
    
    func getUserDetails()
    {
        
        
        guard let get_url = URL(string: "\(ApiService.sharedInstance.baseUrl)user/details") else { return }
        
        var request = URLRequest(url: get_url)
        
        request.httpMethod = "GET"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let access_token = UserDefaults.standard.value(forKey: "access_token") as! String
        request.addValue("Bearer \(access_token)", forHTTPHeaderField: "Authorization")
        
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            //make the request to the teketeke server
            if error != nil {
                print("ERROR FROM REQUEST")
                return
            }
            
            if let content = data {
                
                do{
                    //Array
                    let jsonData = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as! [[String: AnyObject]]
                    if let userinfo = jsonData[0] as [String: AnyObject]? {
                        if let userData = userinfo["data"] as? [String: AnyObject]
                        {
                            let first_name = userData["first_name"] as! String
                            let last_name = userData["last_name"] as! String
                            let phone_number = userData["phone_number"] as! String
                            let email = userData["email"] as! String
                            
                            UserDefaults.standard.setValue(first_name, forKey: "first_name")
                            UserDefaults.standard.setValue(last_name, forKey: "last_name")
                            UserDefaults.standard.setValue(phone_number, forKey: "phone_number")
                            UserDefaults.standard.setValue(email, forKey: "email")
                            UserDefaults.standard.synchronize()
                        }
                    }
                    
                }catch{
                    print(error)
                }
                
                
            }
            
            }.resume()
    }
}
