//
//  NoOrdersViewController.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 17/09/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit

class NoOrdersViewController: UIViewController {

    @IBAction func cancelBtn(_ sender: Any) {
        let vc : AnyObject! = self.storyboard!.instantiateViewController(withIdentifier: "homeview")
        self.show(vc as! UIViewController, sender: vc)
    }
    
    @IBOutlet weak var noOrderLabel: UILabel!
    @IBOutlet weak var noOrderImage: UIImageView!
    
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
