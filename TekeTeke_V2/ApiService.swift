//
//  ApiService.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 12/09/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ApiService: NSObject {
    static let sharedInstance = ApiService()
    
    let baseUrl = "http://dev.teketeke.co/api/"
    let oauth_url = "http://dev.teketeke.co/"
    let image_url = "http://dev.teketeke.co/dummy/"
    
    let basic_delivery_km = 4000
    let delivery_fee_for_4km = 200
    let charge_per_km = 30
    
    //using a completion block to get all outlets
    func fetchOutlets(completion: @escaping ([Outlet]) -> ()){
        let get_url = URL(string: "\(baseUrl)outlets/types")
        URLSession.shared.dataTask(with: get_url!) { (data, response, error) in
            //make the request to the teketeke server
            if error != nil {
                print("ERROR FROM REQUEST")
                return
            }
            let options = JSONSerialization.ReadingOptions.mutableContainers
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: options) as? [String : AnyObject]
                
                var outlets = [Outlet]()
                
                //loop through the return data, convert to a dictinary of array objects
                if let array = json {
                    let image_url = json?["outlet_image_url"] as! String
                    if let fbData = array["data"] as? [[String : AnyObject]] {
                        //fetch the outlets
                        for outlet in fbData {
                            if let outlet_info = outlet["outlets"] as? [AnyObject] {
                                for data in outlet_info {
                                    let outletID = data["id"] as! NSNumber
                                    let outletName = data["name"] as! String
                                    let outletCap = data["caption"] as? String ?? " "
                                    let thumbnailImageName = data["banner"] as? String ?? ""
                                    let outletSlug = data["slug"] as! String
                                    let outletLogo = data["logo"] as? String ?? " "
                                    let outletDesc = data["description"] as? String ?? " "
                                    

                                    
                                    let image_url_string = image_url + thumbnailImageName
                                    outlets.append(Outlet(outletName:outletName, outletCaption: outletCap, outletBannerImage: image_url_string, outletLogoImage: outletLogo, outletMilage: String(describing: outletID), outletDescription: outletDesc, outletSlug: outletSlug)

                                    
                                    )
                                }
                            }
                        }
                    }
                    
                    
                }
                
                DispatchQueue.main.async {
                    completion(outlets) //pass the data to the HomeViewController
                }
            } catch (let parseError){
                print("There was an error parsing the JSON: \"\(parseError.localizedDescription)\"")
            }
            }.resume()
    }
}
