//
//  OutletDetailViewController.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 12/09/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit

class OutletDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var _outletName: String?
    var _outletSlug: String?
    var _outletCaption: String?
    
    @IBOutlet weak var outletBannerImage: UIImageView!
    @IBOutlet weak var outletNameLabel: UILabel!
    @IBOutlet weak var outletDesc: UILabel!
    @IBOutlet weak var mainTable: UITableView!
    @IBOutlet weak var outletLocationLabel: UILabel!
    @IBOutlet weak var mpesaCode: UILabel!
    
    var outletdata = [String]()
    
    var outletProductCategories = [productCategory]()
    
    var milageLabel: String = ""
    var outletnameLabel: String = ""
    var outdesc: String = ""
    var outlocale:String = ""
    var image_url_string: String?
    var outletslug: String = ""
    var outletEmail: String = ""
    var outletStreet: String = ""
    var outletBuilding: String = ""
    var outletTel: String = ""
    var outletID:Int?
    var productID: Int?
    var delivery_fee: String?
    
    var image_link: String?
    
     let activityIndicatorCustom = ActivityIndicator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.init(red: 255/255, green: 0/255, blue: 128/255, alpha: 1)
        navigationItem.title = _outletName
        
        outletDesc.text = _outletCaption
        
        setupNavBar()
        
        if _outletSlug != "" {
            activityIndicatorCustom.show()
            getOutletDetails(slug: _outletSlug!)
        }
    }
    
    func setupNavBar(){
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
        } else {
            // Fallback on earlier versions
        }
    }
    
    func getOutletDetails(slug: Any)  {
        //get single outlet data
        //let the outletProductcategory array to be empty
        outletdata = []
        
        let base_url = ApiService.sharedInstance.baseUrl
        
        guard let url = URL(string: "\(base_url)outlet/\(slug)") else {return}
        
        var request = URLRequest(url: url)
        
        //append the request headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            // query the outlet data and receive the outlet product categories
            if error != nil {
                print(error!)
                return
            }
            if let content = data {
                do {
                    //convert data to array
                    let jsonData = try JSONSerialization.jsonObject(with: content, options: .mutableContainers) as AnyObject
                    
                    var image_url: String = ""
                    var image_banner: String = ""
                    
                    
                    if let outletBanner = jsonData["image_url"] as AnyObject? {
                        image_url = outletBanner as! String
                        self.image_link = outletBanner as? String
                    }
                    
                    
                    if let outletProductCategories = jsonData["product_categories"] as! NSArray? {
                        if outletProductCategories.count != 0 {
                            for data in outletProductCategories {
                                let tdata = data as? [String : AnyObject]
                                let category_name = tdata?["name"] as? String ?? " "
                                let category_slug = tdata?["slug"] as? String
                                let category_image = tdata?["image"] as? String ?? " "
                                let category_desc = tdata?["description"] as? String ?? " "
                                //append the data to the product Category
                                
                                let cate_image = self.image_link! + category_image
                                self.outletProductCategories.append(productCategory(productCategoryName: category_name, productCategorySlug: category_slug!, productCategoryDesc: category_desc, productCategoryImage: cate_image))
                            }
                            
                            DispatchQueue.main.sync {
                                self.mainTable.reloadData()
                            }
                        }else{
                            let success_alert = UIAlertController(title: "No Category Found", message: "Am afraid, No Products are currently listed by \(self._outletName!)", preferredStyle: .alert)
                            success_alert.addAction(UIAlertAction(title: "OK", style:.default, handler: nil))
                            self.present(success_alert, animated: true, completion: nil)
                            
                            DispatchQueue.main.async {
                                self.activityIndicatorCustom.hide()
                            }
                        }
                    }
                    
                    if let outletInfo = jsonData["outlet"] as AnyObject? {
                        let outlet_image = outletInfo["banner"] as? String ?? " "
                        let outlet_id = outletInfo["id"] as! Int
                        let outlet_mpesa_code = outletInfo["mpesa"] as? Int ?? 0
                        image_banner = outlet_image
                        
                        self.outletID = outlet_id
                        DispatchQueue.main.async {
                            self.mpesaCode.text = "MPESA CODE : \(outlet_mpesa_code)"
                        }
                        
                        let image_url_string = "\(image_url + image_banner)"
                        if image_url_string.isEmpty == true {
                            print("no image")
                        }else{
                            self.outletBannerImage.sd_setImage(with: URL(string: image_url_string), placeholderImage: UIImage(named: "iu-3"))
                        }
                        
                        if let addressInfo = outletInfo["address"] as? [String: AnyObject]? {
                        
                            let outlet_email = addressInfo!["email"] as? String ?? " "
                            let outlet_street = addressInfo!["street"] as? String ?? " "
                            let outlet_building = addressInfo!["building"] as? String ?? " "
                            let outlet_telephone = addressInfo!["telephone_1"] as? String ?? " "
                            
                            
                            self.outletdata.append(outlet_email)
                            self.outletdata.append(outlet_street)
                            self.outletdata.append(outlet_building)
                            self.outletdata.append(outlet_telephone)
                            
                            
                            DispatchQueue.main.sync {
                                let outlet_locale = "\(outlet_street)  \(outlet_building)"
                                self.activityIndicatorCustom.hide()
                                self.outletLocationLabel.text = outlet_locale
                            }
                        }
                    }
                } catch {
                    return
                }
            }
            }.resume()
    }
    
    
    //load the tables
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return outletProductCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menucell = mainTable.dequeueReusableCell(withIdentifier: "outletMenuCell", for: indexPath) as! OutletDetailTableViewCell
        
        let index: Int = indexPath.row
        
        menucell.categoryName.text = self.outletProductCategories[index].productCategoryName
        menucell.categoryDesc.text = self.outletProductCategories[index].productCategoryDesc
        menucell.caegoryImage.sd_setImage(with: URL(string: self.outletProductCategories[index].productCategoryImage!), placeholderImage: UIImage(named: "iu-3"))
//        menucell.detailTextLabel?.text = "KSH \(String(self.outletProductCategories[index].productPrice!))"
        
       return menucell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayOutletBanner(image_url: String) {
        let url: String = image_url
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async(execute: {
                let image = UIImage(data: data!)
                self.outletBannerImage.image = image
            })
        }).resume()
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "singleCategory") {
            let indexPath = self.mainTable.indexPathForSelectedRow
            let vc = segue.destination as! OutletProductsViewController
            
            vc._outletID = self.outletID
            vc._outletName = _outletName
            vc._outletSlug = _outletSlug
            vc._categorySlug = outletProductCategories[(indexPath?.row)!].productCategorySlug
            vc.delivery_fee = delivery_fee
            
        } else if (segue.identifier == "customorder"){
            let vc = segue.destination as! CustomOrderViewController
            if let id = self.outletID{
                vc.outletId = id
            }
        }
    }

}
