//
//  CategoryCellCollectionViewController.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 15/09/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit

private let reuseIdentifier = "categoryCell"

class CategoryCellCollectionViewController: UICollectionViewController {

    var CategoryArray: [Category] = []
    
    @IBOutlet weak var collectionview: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    
    override func viewWillAppear(_ animated: Bool) {
        fetchCategories()
    }
    
    
    func fetchCategories(){
            
            CategoryArray = []
            
            let get_categories_url = URL(string: "\(ApiService.sharedInstance.baseUrl)outlets/types")
            
            URLSession.shared.dataTask(with: get_categories_url!) { (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }
                let options = JSONSerialization.ReadingOptions.mutableContainers
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: options) as? [String : AnyObject]
                    
                    if let array = json{
                        if let fbData = array["data"] as? [[String : AnyObject]] {
                            //fetch the categories
                            for eachFetchedCategory in fbData {
                                let eachCategory = eachFetchedCategory as [String: Any]
                                let category = eachCategory["name"] as! String
                                let caption = eachCategory["description"] as! String
                                let slug = eachCategory["slug"] as! String
                                
                                self.CategoryArray.append(Category(categoryName: category, categoryDesc: caption, categorySlug: slug))
                            }
                            DispatchQueue.main.async {
                                self.collectionview?.reloadData()
                            }
                        }
                    }
                } catch(let parseError){
                    print("There was an error parsing the JSON: \"\(parseError.localizedDescription)\"")
                }
                }.resume()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return CategoryArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CategoryNavCollectionViewCell
        
        cell.categoryLabel?.text = String(CategoryArray[indexPath.row].categoryName!)
    
        return cell
    }
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
