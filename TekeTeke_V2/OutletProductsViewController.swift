//
//  OutletProductsViewController.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 15/11/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit

class OutletProductsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {


    @IBOutlet weak var productsCollectionView: UICollectionView!
    let activityIndicatorCustom = ActivityIndicator()
    
    var _outletName: String?
    var _outletSlug: String?
    var _outletID: Int?
    
    var _categorySlug: String?
    
    var outletproductdata = [Product]()
    
    var delivery_fee: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(activityIndicatorCustom)
        
        navigationController?.navigationBar.tintColor = UIColor.init(red: 255/255, green: 0/255, blue: 128/255, alpha: 1)
        navigationItem.title = _outletName
                
        if _outletSlug != "" {
            getProducts()
        }
    }
    
    
    func getProducts() {
        activityIndicatorCustom.show()
        
        //empty the array
        outletproductdata = []
        
        guard let url = URL(string: "\(ApiService.sharedInstance.baseUrl)choice/outlet/\(_outletSlug!)/category/\(_categorySlug!)") else { return }
        
        var request = URLRequest(url: url)
        
        //append the request headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
 
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
                return
            }
            if let content = data {
                do {
                    //convert json data to array
                    let jsonData = try JSONSerialization.jsonObject(with: content, options: .mutableContainers) as AnyObject
                    
                    if let outletProducts = jsonData["chosen_category_products"] as! NSArray? {
                        if outletProducts.count != 0 {
                            for data in outletProducts {
                                let tdata = data as? [String : AnyObject]
                                let product_id = tdata?["id"] as! Int
                                let product_name = tdata?["name"] as! String
                                let product_description = tdata?["description"] as? String ?? " "
                                let product_slug = tdata?["slug"] as! String
                                let product_price = tdata?["price"] as! Int
                                var product_image = tdata?["image"] as? String ?? " "
                                
                                product_image = ApiService.sharedInstance.image_url + product_image
                                
                                
                                //append the data to the product array
                                self.outletproductdata.append(Product(productSlug: product_slug, productName: product_name, productDescription: product_description, productImage: product_image, productPrice: String(product_price), productID: product_id))
                            }
                            
                            DispatchQueue.main.async {
                                self.activityIndicatorCustom.hide()
                                self.productsCollectionView.reloadData()
                            }
                            
                            
                        }else{
                            let success_alert = UIAlertController(title: "No Products Found", message: "Am afraid, No Products are currently listed by \(self._outletName!)", preferredStyle: .alert)
                            success_alert.addAction(UIAlertAction(title: "OK", style:.default, handler: nil))
                            self.present(success_alert, animated: true, completion: nil)
                        }
                        
                    }
                } catch {
                    return
                }
            }
        }.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return outletproductdata.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = productsCollectionView.dequeueReusableCell(withReuseIdentifier: "productCell", for: indexPath) as! OutletProductsCollectionViewCell
        
        let index = indexPath.row
        cell.productName.text = outletproductdata[index].productName
        cell.productPrice.text = outletproductdata[index].productPrice
        cell.productImage.sd_setImage(with: URL(string: "\(ApiService.sharedInstance.image_url)/\(outletproductdata[index].productImage!)" ), placeholderImage: UIImage(named: "iu-3"))
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! OutletProductsCollectionViewCell
        let indexPath = self.productsCollectionView.indexPath(for: cell)

        
        let vc = segue.destination as! ProductViewController
        vc.item_name = (cell.productName?.text)!
        vc.item_price = Int(outletproductdata[(indexPath?.row)!].productPrice!)
        vc.product_Image = outletproductdata[(indexPath?.row)!].productImage
        vc.outletID = _outletID!
        vc.productID = outletproductdata[(indexPath?.row)!].productID!
        vc.delivery_fee = self.delivery_fee
    }
}
