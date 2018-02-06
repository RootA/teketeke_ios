//
//  JSQMessagesViewController.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 10/10/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import JSQMessagesViewController
import Firebase

struct UserM {
    let id: String
    let name: String
}


class JSQChatMessagesViewController: JSQMessagesViewController {
    
    var chatId: String? 
    
    let user1 = UserM(id: "1", name: UserDefaults.standard.value(forKey: "first_name") as! String)
    let user2 = UserM(id: "2", name: "Customer Care")
    
    var currentUser: UserM {
        return user1
    }
    



    
    // all messages of users1, users2
    var messages = [JSQMessage]()
}

extension JSQChatMessagesViewController {

    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!)
    {
//        let values = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
//        let ref = Constants.refs.databaseChats.childByAutoId()
        let ref = Database.database().reference().child(self.chatId!)
        let childRef = ref.childByAutoId()
        let message = ["sender_id": senderId, "name": senderDisplayName, "message": text]
        childRef.updateChildValues(message as Any as! [AnyHashable : Any])
        
//        messages.append(values!)
        
        finishSendingMessage()
    }

    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.row]
        let messageUsername = message.senderDisplayName
        
        return NSAttributedString(string: messageUsername!)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        let message = messages[indexPath.row]
        
        if currentUser.id == message.senderId {
            return bubbleFactory?.outgoingMessagesBubbleImage(with: .green)
        } else {
            return bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.init(red: 52/255, green: 152/255, blue: 219/255, alpha: 1))
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
}

extension JSQChatMessagesViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBar()
        
        // tell JSQMessagesViewController
        // who is the current user
//        self.senderId = currentUser.id
        self.senderId = chatId
        self.senderDisplayName = currentUser.name
        
        
        inputToolbar.contentView.leftBarButtonItem = nil
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        let query = Database.database().reference().child(self.chatId!).queryLimited(toLast: 10)
        
        _ = query.observe(.childAdded, with: { [weak self] snapshot in
            
            if  let data        = snapshot.value as? [String: String],
                let id          = data["sender_id"],
                let name        = data["name"],
                let text        = data["message"],
                !text.isEmpty
            {
                if let message = JSQMessage(senderId: id, displayName: name, text: text)
                {
                    self?.messages.append(message)
                    
                    self?.finishReceivingMessage()
                }
            }
        })
        
//        self.messages = getMessages()
    }
    
  
    func setNavigationBar() {
        let screenSize: CGRect = UIScreen.main.bounds
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 64))
        let navItem = UINavigationItem(title: "CHAT LOG")
        let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: nil, action: #selector(done))
        navItem.rightBarButtonItem = doneItem
        navBar.setItems([navItem], animated: false)
        
        
        self.view.addSubview(navBar)
    }
    
    func done() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension JSQChatMessagesViewController {
    func getMessages() -> [JSQMessage] {
        var messages = [JSQMessage]()
        
        // get all messages from Firebase
        
        
        let message1 = JSQMessage(senderId: "1", displayName: "Steve", text: "Hey Tim how are you?")
        let message2 = JSQMessage(senderId: "2", displayName: "Tim", text: "Fine thanks, and you?")
        
        messages.append(message1!)
        messages.append(message2!)
        
        return messages
    }
}

