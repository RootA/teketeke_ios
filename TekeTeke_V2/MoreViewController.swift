//
//  MoreViewController.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 14/09/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit

class MoreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var mainTableView: UITableView!
    
    
    //hide keyboard when not in use
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
        
        mainTableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView
        : UITableView) -> Int {
        return 2
    }
    
    let tableMenu = [
        ("Menu", "Order Anything"),
        ("Promo Code", "Add A Promo Code"),
        ("Update My Location", "Update My Location")
    ]
    
    let aboutMenu = [
        ("Contact Support","Contact Support"),
        ("Chat with us", "Chat With Us"),
        ("Like Us", "Like Us Facebook"),
        ("FAQ", "FAQ"),
        ("Terms & Conditons", "Terms & Conditons")
    ]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return tableMenu.count
        } else {
            return aboutMenu.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let categorycell = mainTableView.dequeueReusableCell(withIdentifier: "moreCell", for: indexPath) as! MoreTableViewCell
        let index: Int = indexPath.row
        
        if indexPath.section == 0 {
            let (_, MenuContent) = tableMenu[index]
            categorycell.textLabel?.text = MenuContent
        }else {
            let (_, MenuContent) = aboutMenu[index]
            categorycell.textLabel?.text = MenuContent
        }
        
        return categorycell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.row
        if indexPath.section == 0 {
            switch(section) {
            case 0:
                //handles section with order anything
                //call the order anything tab modally
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc : MoreCustomOrderViewController = storyboard.instantiateViewController(withIdentifier: "moreCustomOrder") as! MoreCustomOrderViewController
                self.present(vc, animated: true, completion: nil)
                break
            case 1:
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc : PromoCodeViewController = storyboard.instantiateViewController(withIdentifier: "promocode") as! PromoCodeViewController
                self.present(vc, animated: true, completion: nil)
                break
            case 2:
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc : updatelocationViewController = storyboard.instantiateViewController(withIdentifier: "updatelocation") as! updatelocationViewController
                self.present(vc, animated: true, completion: nil)
                break
            default:
                print("Anything Goes")
            }
        } else {
        switch (section) {
        case 0:
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc : ContactUsViewController = storyboard.instantiateViewController(withIdentifier: "contactus") as! ContactUsViewController
            self.present(vc, animated: true, completion: nil)
            break
        case 1:
            //customer support
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc : ChatsStatusViewController = storyboard.instantiateViewController(withIdentifier: "openChatSegue") as! ChatsStatusViewController
            self.present(vc, animated: true, completion: nil)
            break
        case 2:
            //like us on facebook
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc : LikesonfbViewController = storyboard.instantiateViewController(withIdentifier: "likeusonfb") as! LikesonfbViewController
            self.present(vc, animated: true, completion: nil)
            break
        case 3:
            //faq
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc : FaqViewController = storyboard.instantiateViewController(withIdentifier: "faq") as! FaqViewController
            self.present(vc, animated: true, completion: nil)
            break
        case 4:
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc : TermsandConditionsViewController = storyboard.instantiateViewController(withIdentifier: "terms") as! TermsandConditionsViewController
            self.present(vc, animated: true, completion: nil)
            break
        default:
            print("Anything goes here")
        }
      }
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
