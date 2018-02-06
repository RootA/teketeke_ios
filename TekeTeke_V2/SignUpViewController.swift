//
//  SignUpViewController.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 14/09/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var UIscrollView: UIScrollView!
    
    //hide keyboard when not in use
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //presses return key
    private func searchBarTextDidEndEditing(_ searchBar: UISearchBar) -> Bool {
        return (true)
    }
    
    @IBAction func signUpUser(_ sender: Any) {
        //declare the endpoin to use for user registration
        
        let first_name = firstName.text
        let last_name = lastName.text
        let email = emailAddress.text
        let phone_number = phoneNumber.text
        let password = Password.text
        
        
        
        if (first_name! == "" || last_name! == "" ||  email! == "" || password! == "") {
            return
        }
        
        let parameters = [
            "first_name": first_name,
            "last_name": last_name,
            "email": email,
            "phone_number": phone_number,
            "password": password
        ]
        
        
        guard let url = URL(string: "\(ApiService.sharedInstance.baseUrl)new_user") else { return }
        
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
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
                        let vc : AnyObject! = self.storyboard!.instantiateViewController(withIdentifier: "homeview")
                        self.show(vc as! UIViewController, sender: vc)
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
