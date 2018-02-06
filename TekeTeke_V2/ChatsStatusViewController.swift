//
//  ChatsStatusViewController.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 03/10/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit

class ChatsStatusViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var openChats: [Chat] = []
    var globalSetter: Bool = true
    
    let activityIndocatorCustom = ActivityIndicator()
    
    @IBOutlet weak var chatTableView: UITableView!
    
    @IBAction func refreshBtn(_ sender: Any){
        refreshData()
    }
    
    @IBAction func cancelBtn(_ sender: Any){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addChatBtn(_ sender: Any) {
        initiateChat()
        let success_alert = UIAlertController(title: "Requesting", message: "Hold on as we request an Agent for you, Press the refresh button later, THANK YOU", preferredStyle: .alert)
        success_alert.addAction(UIAlertAction(title: "OK", style:.default, handler: { (action) in  self.refreshData() }))
        self.present(success_alert, animated: true, completion: nil)
    }
    
    func refreshData(){
        getOpenChats()
//        self.chatTableView.reloadData()
    }
    
    func initiateChat(){
//        activityIndocatorCustom.show()
        guard let chatUrl = URL(string: "\(ApiService.sharedInstance.baseUrl)chats/create") else { return }
        
        var request = URLRequest(url: chatUrl)
        
        
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
                    if let results = jsonData["data"]! as AnyObject? {
                        print(results)
                    }
                    DispatchQueue.main.async {
//                        self.activityIndocatorCustom.hide()
                        self.chatTableView.reloadData()
                    }
                }
                catch{
                    print(error)
                }
            }
            }.resume()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getOpenChats()
    }
    
    func getOpenChats(){
//        activityIndocatorCustom.show()
        openChats = []
        
        guard let chatUrl = URL(string: "\(ApiService.sharedInstance.baseUrl)chats/conversations") else { return }
        
        var request = URLRequest(url: chatUrl)
        
        
        //append the request headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        if let access_token = UserDefaults.standard.value(forKey: "access_token") as? String {
            request.addValue("Bearer \(access_token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Please Login")
        }

        let session = URLSession.shared
        
        session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print("ERROR FROM REQUEST")
                return
            }
            do {
                //convert to an array
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as AnyObject
                if let chatData = json["data"] as! NSArray? {
                    if chatData.count == 0 {
                        //no chat history
                    } else {
                        for content in chatData {
                            let tdata = content as? [String : AnyObject]
                            let customerName = tdata!["customer_care"] as? String ?? "No Chat"
                            let chat_public_id = tdata!["public_id"] as? String ?? "No Chat"
                            let chat_status = tdata!["status"] as? Int ?? 0
                            
                            self.openChats.append(Chat(chatId: chat_public_id, teketeke_staff: customerName , chatStatus: chat_status))
                        }
                            DispatchQueue.main.async {
//                                self.activityIndocatorCustom.hide()
                                self.chatTableView.reloadData()
                            }
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
        chatTableView.delegate = self
        chatTableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return openChats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let openChatCell = chatTableView.dequeueReusableCell(withIdentifier: "openChats", for: indexPath) as! OpenChatsTableViewCell
        openChatCell.customerCare.text = openChats[indexPath.row].teketeke_staff
        if openChats[indexPath.row].chatStatus == 0 {
             openChatCell.status.text = "   Open Chat Session"
        } else {
            
            openChatCell.status.text = "   Closed Chat"
            globalSetter = false
        }
        return openChatCell
    }
    
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        let indexPath = self.chatTableView.indexPathForSelectedRow
//        let chatUI = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
//        chatUI.chatId = openChats[(indexPath?.row)!].chatId!
//        print("chatUI : \(String(describing: chatUI.chatId))")
//        let navController = UINavigationController(rootViewController: chatUI)
//        present(navController, animated: true, completion: nil)
//
//    }

//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let chatUI = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
////        navigationController?.pushViewController(chatUI, animated: true)
//        chatUI.chatId = openChats[indexPath.row].chatId
//        navigationController?.pushViewController(chatUI, animated:true)
////        self.present(chatUI, animated: true, completion: nil)
//
//    }
//
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if globalSetter {
            if (segue.identifier == "chatBotSegue") {
                let indexPath = self.chatTableView.indexPathForSelectedRow
                let vc = segue.destination as! JSQChatMessagesViewController
                vc.chatId = openChats[(indexPath?.row)!].chatId!
            }
        }
        //return an alert to show chat session is over
//        let success_alert = UIAlertController(title: "Sorry", message: "Press the + button to request an Agent for you, Press the refresh button later, THANK YOU", preferredStyle: .alert)
//        success_alert.addAction(UIAlertAction(title: "OK", style:.default, handler: nil))
//        self.present(success_alert, animated: true, completion: nil)
    }
    
    

}
