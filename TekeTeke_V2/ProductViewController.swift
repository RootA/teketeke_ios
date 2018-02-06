//
//  ProductViewController.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 13/09/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit
import CoreData

class ProductViewController: UIViewController {

    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var qtyLabel: UILabel!
    
    @IBOutlet weak var itemPriceTag: UILabel!
    
    @IBOutlet weak var ingridentsTab: UILabel!
    
    @IBOutlet weak var ingridentsInfo: UILabel!
    @IBOutlet weak var quantityLabelText: UILabel!
    
    @IBOutlet weak var productImage: UIImageView!
    
    @IBOutlet weak var ItembyQuantityTotal: UILabel!
    
    var item_name:String = ""
    var item_price: Int?
    var item_desc: String = ""
    
    var outletID: Int = 0
    var productID: Int = 0
    var product_Image: String?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var cartArray:[Cart] = []
    var CurrentOutletID: [Any] = []
    var glo_outlet_ID: Int?
    
    var delivery_fee: String?
    
    // modify the value of the qty on pressing the stepper
    @IBAction func quantityStepper(_ sender: UIStepper) {
        let qty = Int(sender.value).description
        let price = item_price
        qtyLabel.text = qty
        let total_price = price! * Int(qty)!
        ItembyQuantityTotal.text = String(total_price)
    }
    
    @IBAction func orderButton(_ sender: Any) {
        //make an order when button is pressed
        //get the order details
        let outlet_ID = outletID
        let product_ID = productID
        let price_tag = item_price
        let qty = qtyLabel.text
        let subtotal = ItembyQuantityTotal.text
        let product_name = item_name
        
        //save the current outlet_id into memory
      
        if  glo_outlet_ID == nil {
            addToCart(product_name: product_name, product_id: product_ID, outlet_id: outlet_ID, quantity: Int(qty!)!, price: Int(price_tag!) , subtotal: Int(subtotal!)!, commision_tax: 16)
        } else if glo_outlet_ID != outletID {
            let clear_alert = UIAlertController(title: "Cannot Place Order On More Than One Outlet", message: "Clear Basket ? ", preferredStyle: .alert)
            clear_alert.addAction(UIAlertAction(title: "Cancel", style:.default, handler: nil))
            clear_alert.addAction(UIAlertAction(title: "Clear", style:.destructive, handler: { (action) in self.clearBasket()}))
            self.present(clear_alert, animated: true, completion: nil)
        }
    }
    
    func addToCart(product_name: String, product_id: Int, outlet_id: Int, quantity:Int, price: Int, subtotal: Int, commision_tax: Double){
        
        let newCart = NSEntityDescription.insertNewObject(forEntityName: "Cart", into: context)
        
        newCart.setValue(product_name, forKey: "product_name")
        newCart.setValue(product_id, forKey: "product_id")
        newCart.setValue(outlet_id, forKey: "outlet_id")
        newCart.setValue(quantity, forKey: "quantity")
        newCart.setValue(price, forKey: "item_price")
        newCart.setValue(subtotal, forKey: "subtotal")
        newCart.setValue(commision_tax, forKey: "commission_tax")
        newCart.setValue(Int(delivery_fee!), forKey: "delivery_fee")
        
        do{
            try context.save()
            updateTabBarBadge()
            
            //show an alert after it successfully added to basket
            let success_alert = UIAlertController(title: "Success", message: "Item successfully added to basket", preferredStyle: .alert)
            success_alert.addAction(UIAlertAction(title: "OK", style:.default, handler: nil))
            self.present(success_alert, animated: true, completion: nil)
            
        }catch{
//            return
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)") //remove during production
        }
        
    }//end of function
    
    func updateTabBarBadge(){
        do{
            cartArray = try context.fetch(Cart.fetchRequest())
            tabBarController?.tabBar.items?[2].badgeValue = String(cartArray.count)
        }
        catch{
            print(error)
        }
    }
    
    func clearBasket(){
        do{
            cartArray = try self.context.fetch(Cart.fetchRequest())
            for data in cartArray {
                self.context.delete(data)
            }
            tabBarController?.tabBar.items?[2].badgeValue = String(cartArray.count)
            
            DispatchQueue.main.async {
                self.viewDidLoad()
            }
        }
        catch{
            print("Could not delete the data : \(error)" )
        }
    }
    
    func getOutletCartId(){
        do{
            let results = try self.context.fetch(Cart.fetchRequest())
            
            for result in results as! [NSManagedObject] {
                glo_outlet_ID =  result.value(forKey: "outlet_id")! as? Int
            }
        }catch{}
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = UIColor.init(red: 255/255, green: 0/255, blue: 128/255, alpha: 1)

        itemName.text = item_name
        itemPriceTag.text = " KSH \(item_price!)"
        ItembyQuantityTotal.text = String(item_price!)
        let product_img = "\(ApiService.sharedInstance.image_url)\(product_Image!)"
        displayProductBanner(image_url: product_img)
        
        getOutletCartId()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayProductBanner(image_url: String) {
        let url: String = image_url
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async(execute: {
                let image = UIImage(data: data!)
                self.productImage.image = image
            })
        }).resume()
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
