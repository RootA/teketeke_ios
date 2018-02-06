//
//  PasswordChangeViewController.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 02/10/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit

class PasswordChangeViewController: UIViewController {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var newPasswordTextfield: UITextField!
    @IBAction func savePassword(_ sender: Any){
        //get the new password
        let newPassword = newPasswordTextfield?.text
        if newPassword?.isEmpty == true {
            return
        }
        
        updatePassword(parameters: newPassword!)
    }
    
    func updatePassword(parameters: String){
        guard let password_update_url = URL(string: "\(ApiService.sharedInstance.baseUrl)/password/chage") else { return }
        
        var request = URLRequest(url: password_update_url)
        
        request.httpMethod = "GET"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        request.addValue("Bearer \(UserDefaults.standard.value(forKey: "access_token")!)", forHTTPHeaderField: "Authorization")
        
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
                        let success_alert = UIAlertController(title: "Success", message: "Password has successfully been updated", preferredStyle: .alert)
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
