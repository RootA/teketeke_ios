//
//  LikesonfbViewController.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 09/11/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit

class LikesonfbViewController: UIViewController, UIWebViewDelegate {

    
    @IBOutlet weak var fbpage: UIWebView!
    
    @IBAction func closeUI(){
        self.dismiss(animated: true, completion: nil)
    }
    
    let activityIndicatorCustom = ActivityIndicator()

    
    override func viewWillAppear(_ animated: Bool) {
        loadFb()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(activityIndicatorCustom)
    }

    func loadFb(){
        let url = URL(string: "https://web.facebook.com/teketekeservices/?_rdc=1&_rdr")
        
        let request = URLRequest(url: url!)
        
        let session = URLSession.shared

        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            if error == nil {
                if data != nil {
                    DispatchQueue.main.async {
                        self.fbpage.loadRequest(request)
                        self.activityIndicatorCustom.hide()
                    }
                }
            } else {
                print("Error \(error ?? " Error handling " as! Error)")
            }
        })
        task.resume()
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
