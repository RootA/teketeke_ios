//
//  SearchViewController.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 13/09/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate {

    @IBOutlet weak var searchField: UISearchBar!
    @IBOutlet weak var categories: UILabel!
    @IBOutlet weak var mainSearchTableView: UITableView!
    
    var categoriesFetched = [Category]()
    var outlets: [Outlet] = []
    
    var lat: Double = -1.3172524
    var lng: Double = 36.8095495
    
    let activityIndicatorCustom = ActivityIndicator()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        
        mainSearchTableView.dataSource = self
        searchField.delegate = self
        self.view.addSubview(activityIndicatorCustom)
        fetchCategories()
    }
    
    func setupNavBar(){
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
    }

    //hide keyboard when not in use
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //presses return key
    private func searchBarTextDidEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchField.resignFirstResponder()
        return (true)
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        activityIndicatorCustom.show()
        
        outlets = []
        
        let search_term = searchField.text
        
        guard let search_url = URL(string: "\(ApiService.sharedInstance.baseUrl)search") else { return }
        
        let parameters = [
            "lat" : lat,
            "lng" : lng,
            "search_term" : search_term!
            ] as [String : Any]
        
        
        var request = URLRequest(url: search_url)
        
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(UserDefaults.standard.value(forKey: "access_token")!)", forHTTPHeaderField: "Authorization")
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response,error) in
            if error != nil {
                print(error.debugDescription)
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as AnyObject
                    if let results = json["results"] as AnyObject? {
                        if results as! Int  != 0  {
                            if let outletResponse = json["outlets"] as! NSArray? {
                                for data in outletResponse as NSArray {
                                    let tdata = data as? [String : AnyObject]
                                    let outlet_name = tdata?["name"] as! String
                                    let outlet_milage = tdata?["coordinates"] as! String
                                    let outlet_desc = tdata?["description"] as! String
                                    let outlet_slug = tdata?["slug"] as! String
                                    let outlet_caption = tdata?["caption"] as! String
                                    let outlet_banner = tdata?["banner"] as! String
                                    let outlet_logo = tdata?["logo"] as! String
                                    
                                    let image_string = "\(ApiService.sharedInstance.oauth_url)dummy/\(outlet_banner)"
                                    //append the data to the outlets array
                                    self.outlets.append(Outlet(outletName: outlet_name, outletCaption: outlet_caption, outletBannerImage: image_string, outletLogoImage: outlet_logo, outletMilage: outlet_milage, outletDescription: outlet_desc, outletSlug: outlet_slug))
                                }
                                
                                DispatchQueue.main.async {
                                    self.activityIndicatorCustom.hide()
                                    //push content to a different screen board
                                    let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                    let vc : SearchResultsViewController = storyboard.instantiateViewController(withIdentifier: "searchResults") as! SearchResultsViewController
                                    
                                    vc.outlets = self.outlets
                                    self.present(vc, animated: true, completion: nil)
                                }
                            }
                        }else {
                            self.activityIndicatorCustom.hide()
                            //do something if nothing is found on search
                            let success_alert = UIAlertController(title: "No data", message: "Sorry, we couldn't find what you are looking for", preferredStyle: .alert)
                            success_alert.addAction(UIAlertAction(title: "OK", style:.default, handler: nil))
                            self.present(success_alert, animated: true, completion: nil)
                        }
                    }
                    
                }catch {
                    print(error)
                }
            }
            }.resume()
        self.view.endEditing(true)
    }
    
    func fetchCategories(){
        activityIndicatorCustom.show()
        categoriesFetched = []
        
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
                            
                            self.categoriesFetched.append(Category(categoryName: category, categoryDesc: caption, categorySlug: slug))
                        }
                        DispatchQueue.main.async {
                            self.activityIndicatorCustom.hide()
                            self.mainSearchTableView.reloadData()
                        }
                    }
                }
            } catch(let parseError){
                print("There was an error parsing the JSON: \"\(parseError.localizedDescription)\"")
            }
            }.resume()
    }
    
    let tableMenu = [
        ("Closest outlets to you", "Search by Location")
    ]
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return categoriesFetched.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let categorycell = mainSearchTableView.dequeueReusableCell(withIdentifier: "searchableContentCell", for: indexPath) as! SearchTableViewCell
        let index: Int = indexPath.row

            categorycell.textLabel?.text = self.categoriesFetched[index].categoryName
            categorycell.detailTextLabel?.text  = self.categoriesFetched[index].categoryDesc

        return categorycell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "categorySelectedSegue" {
            let categorySelected = self.mainSearchTableView.indexPathForSelectedRow
            let cell = mainSearchTableView.cellForRow(at: categorySelected!)
            let vc = segue.destination as! OutletFeedViewController
           vc.categorySlug =  categoriesFetched[(categorySelected?.item)!].categorySlug!
           vc.categoryName = cell?.textLabel?.text
        } else {
            
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   

}
