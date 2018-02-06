//
//  ChatBoxViewController.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 02/10/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit

let DEBUG_CUSTOM_TYPING_INDICATOR = false

class ChatBoxViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var messages: [Chat] = []
    var chatId: Any?
    var public_id: String?
    @IBOutlet weak var mainTableView: UITableView!
    
    @IBOutlet weak var chatTextfield: UITextField!
    
    let activityIndicatorCustom = ActivityIndicator()
    
    @IBAction func doneBtn(_ sender: Any){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendButton(_ sender: Any){
        self.chatTextfield.resignFirstResponder()
        if chatTextfield != nil {
            if UserDefaults.standard.value(forKey: "access_token") != nil {
                //post the message
                let message_parameters = [
                    "message" : chatTextfield?.text! as Any
                ]
                print(message_parameters)
                postMessage(message: message_parameters)
            }else{
                //No user is signed in
                print("you need to sign in")
            }
            self.chatTextfield.text = nil
        }else{
            print("Error: Empty String")
            return
        }
    }
    
    func postMessage(message: Any){
        activityIndicatorCustom.show()
        guard let chatUrl = URL(string: "\(ApiService.sharedInstance.baseUrl)chats/message/\(chatId!)") else { return }
        print(chatUrl)
        var request = URLRequest(url: chatUrl)
        
        request.httpMethod = "POST"
        //append the request headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let access_token = UserDefaults.standard.value(forKey: "access_token") as! String
        request.addValue("Bearer \(access_token)", forHTTPHeaderField: "Authorization")
        
        
        let jsonData = try? JSONSerialization.data(withJSONObject: message, options: .prettyPrinted)
        
        request.httpBody = jsonData
        
        let session = URLSession.shared
        
        session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print("ERROR FROM REQUEST")
                return
            }
            do {
                //convert to an array
                _ = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as AnyObject
                
                DispatchQueue.main.async {
                    self.activityIndicatorCustom.hide()
                }
                
            } catch {
                print(error)
                return
            }
            }.resume()
    }
 
    
    override func viewWillAppear(_ animated: Bool) {
        getMessages()
    }
    
    func getMessages(){
        guard let chatUrl = URL(string: "\(ApiService.sharedInstance.baseUrl)chats/conversations/\(public_id!)") else { return }

            var request = URLRequest(url: chatUrl)

            //append the request headers
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")

            let access_token = UserDefaults.standard.value(forKey: "access_token") as! String
            request.addValue("Bearer \(access_token)", forHTTPHeaderField: "Authorization")

            let session = URLSession.shared

            session.dataTask(with: request) { (data, response, error) in
                if error != nil {
                    print("ERROR FROM REQUEST")
                    return
                }
                do {
                    //convert to an array
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as AnyObject
                        if let _ = json["data"] as AnyObject? {
                            DispatchQueue.main.async {
                                self.activityIndicatorCustom.hide()
                            }
                        }
                    } catch {
                        print(error)
                        return
                    }
                }.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicatorCustom.show()
        hideKeyboardWhenTappedAround()
    }

 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageSnapShot = messages[indexPath.row]
        let message = messageSnapShot.dictionaryWithValues(forKeys: ["message"])
        let messageId = message["senderid"] as? String
        
        //check where the sender and mesage id correspond
        if messageId == "1" {
            let cell = mainTableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ChatTableViewCell
            cell.configCell(message: message)
            return cell
        }else {
            let cell = mainTableView.dequeueReusableCell(withIdentifier: "chatCell2", for: indexPath) as! ChatTableViewCell
            cell.configCell(message: message)
            return cell
        }
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
