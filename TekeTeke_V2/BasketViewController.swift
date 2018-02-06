//
//  BasketViewController.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 14/09/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit
import CoreData
import XLActionController

class BasketViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var cartArray:[Cart] = []
    
    @IBOutlet weak var cartItems: UITableView!
    
    @IBOutlet weak var subTotalLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var grandTtlLabel: UILabel!
    @IBOutlet weak var outlet_delivery_fee: UILabel!
    @IBOutlet weak var totalItemsLabel: UILabel!
    
    @IBOutlet weak var totalCost: UILabel!
    
    let activityIndicatorCustom = ActivityIndicator()
    var delivery_fee: Int?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBAction func promoCode(_ sender: Any) {
        //load an action sheet with text input
        let promoBox = UIAlertController(title: "PROMO CODE", message: "Enter Your Promo Code", preferredStyle: .alert)
        promoBox.addAction(UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            let textField = promoBox.textFields![0] as UITextField
            // add to cart Array
            self.addtoCartArray(parameters: textField.text!)
            
        }))
        promoBox.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        promoBox.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
            textField.placeholder = "Enter Code"
        })
        
        self.present(promoBox, animated: true, completion: nil)
    }
    
    
    func addtoCartArray(parameters: Any){
        let new_parameters = [
            "code" : parameters
        ]
        guard let promoCodeUrl = URL(string: "\(ApiService.sharedInstance.baseUrl)codes/confirm") else { return }
        
        var request = URLRequest(url: promoCodeUrl)
        
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(UserDefaults.standard.value(forKey: "access_token")!)", forHTTPHeaderField: "Authorization")
        
        let jsonData = try? JSONSerialization.data(withJSONObject: new_parameters, options: .prettyPrinted)
        
        request.httpBody = jsonData
        
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print("ERROR FROM REQUEST")
                return
            }
            do {
                //convert to an array
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as AnyObject
                
                if let response = json["message"] as AnyObject? {
                    let data = response as! String
                    
                    //perform an alert message
                    let success_alert = UIAlertController(title: "Alert", message: data, preferredStyle: .alert)
                    success_alert.addAction(UIAlertAction(title: "OK", style:.default, handler: nil))
                    self.present(success_alert, animated: true, completion: nil)
                }
            } catch {
                print(error)
                return
            }
            }.resume()
        
    }
    @IBAction func checkoutButton(_ sender: Any) {
        if UserDefaults.standard.value(forKey: "access_token") == nil {
            handleLogin()
        }
    }
    
    func handleLogin(){
        //handle sign in
        print("do sign in")
    }
    
    func handleCheckout(){
        //push data to the next controller
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if UserDefaults.standard.value(forKey: "access_token") == nil {
            handleLogin()
        }else {
            if segue.identifier == "checkoutSegue" {
                let vc = segue.destination as! CompleteOrderViewController
                vc.parameters = cartArray
                vc.delivery_fee = delivery_fee!
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cartItems.delegate = self
        cartItems.dataSource = self
        
        // load items from the cart
        fetchCartItems()
        if cartArray.isEmpty {
            //show no orders tab
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc : NoOrdersViewController = storyboard.instantiateViewController(withIdentifier: "no_order") as! NoOrdersViewController
            self.present(vc, animated: true, completion: nil)

        }
        self.cartItems.reloadData()
        getTotal()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
    }
    
    func setupNavBar(){
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    
    func getTotal(){
        var total_price: Int = 0
        for price in cartArray {
            total_price = Int(price.subtotal) + total_price
        }
        let commission = 0.16 * Double(total_price)
        
        subTotalLabel?.text = String(total_price)
        taxLabel?.text = String(Int(commission))
        if let fee = delivery_fee {
            outlet_delivery_fee?.text = "\(fee)"
            totalCost?.text = "KSH \(total_price + Int(commission) + fee)"
            grandTtlLabel?.text = "\(total_price + Int(commission) + fee)"
        }
    }
    
    func fetchCartItems(){
        do{
            cartArray = try context.fetch(Cart.fetchRequest())
            for result in cartArray as [NSManagedObject] {
                delivery_fee =  result.value(forKey: "delivery_fee")! as? Int
            }
            tabBarController?.tabBar.items?[2].badgeValue = String(cartArray.count)
        }
        catch{
            print(error)
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cartdataCell = cartItems.dequeueReusableCell(withIdentifier: "cartitemsCell", for: indexPath) as! BasketTableViewCell
        let cart = cartArray[indexPath.row]
        
        cartdataCell.itemNameLabel?.text = cart.product_name
        cartdataCell.itemPriceLabel?.text = "\(cart.item_price) ksh"
        cartdataCell.itemQtyLabel?.text = "x \(cart.quantity)"
        let totalPrice = cart.item_price * cart.quantity
        cartdataCell.Total?.text = "Ksh \(totalPrice)"
        
        return cartdataCell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            let index = cartArray[indexPath.row]
//            cartArray.remove(at: indexPath.row) //will remove the array object on sliding on the table row
//
//            //delete from core data
//            context.delete(index)
//
//            do{
//                try context.save()
//                tabBarController?.tabBar.items?[2].badgeValue = String(cartArray.count)
//
//            } catch let error as NSError {
//                print("Error occuredon deleting object \(error)")
//            }
//            getTotal()
//            cartItems.reloadData() //refresh the table view after editing
//
//        }
//    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            // delete item at indexPath
            let index = self.cartArray[indexPath.row]
            self.cartArray.remove(at: indexPath.row) //will remove the array object on sliding on the table row
            
            //delete from core data
            self.context.delete(index)
            
            do{
                try self.context.save()
                self.tabBarController?.tabBar.items?[2].badgeValue = String(self.cartArray.count)
                
            } catch let error as NSError {
                print("Error occuredon deleting object \(error)")
            }
            self.getTotal()
            self.cartItems.reloadData() //refresh the table view after editing
        }
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            // share item at indexPath
            let index = self.cartArray[indexPath.row]
            
            let actionController = SkypeActionController()
            actionController.addAction(Action("Update Qty", style: .default, handler: { action in self.modifyQty(item: index)}))
            actionController.addAction(Action("Clear Basket", style: .destructive, handler: { (action) in self.clearBasket()}))
            actionController.addAction(Action("Cancel", style: .cancel, handler: nil))
            self.present(actionController, animated: true, completion: nil)
        }
        
        edit.backgroundColor = UIColor.blue
        
        return [delete, edit]
    }
    func modifyQty(item: Any){
        
        //load an action sheet with text input
        let qtyBox = UIAlertController(title: "Update", message: "New Quantity", preferredStyle: .alert)
        qtyBox.addAction(UIAlertAction(title: "Update", style: .destructive, handler: {
            alert -> Void in
            let textField = qtyBox.textFields![0] as UITextField
            // Push the data for CoreData to process
            self.updateCoreData(newQty: Int(textField.text!)!)
        }))
        qtyBox.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        qtyBox.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
            textField.placeholder = "Enter Qty"
        })
        
        self.present(qtyBox, animated: true, completion: nil)
    }
    
    func updateCoreData(newQty: Int){
        activityIndicatorCustom.show()
        print("new Qty to update : " , newQty)
        do {
            let results = try self.context.fetch(Cart.fetchRequest())
            
            if results.count > 0 {
                var price: Int?
                
                let item = results[0] as! NSManagedObject
                if let item_price = item.value(forKey: "item_price") {
                    price = item_price as? Int
                }
                
                let subttl = price! * newQty
                
                if let _ = item.value(forKey: "quantity") {
                    
                    item.setValue(newQty, forKey: "quantity")
                    item.setValue(subttl, forKey: "subtotal")
                    
                    do {
                        try item.managedObjectContext?.save()
                        
                        DispatchQueue.main.async {
                            self.activityIndicatorCustom.hide()
                            self.cartItems.reloadData()
                            self.getTotal()
                        }
                    } catch {
                        let saveError = error as NSError
                        print(saveError)
                    }
                }
            }
        } catch {
            
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
                self.cartItems.reloadData()
                self.getTotal()
            }
        }
        catch{
            print("Could not delete the data : \(error)" )
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
