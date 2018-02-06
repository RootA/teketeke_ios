//
//  SearchResultsViewController.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 26/10/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit

class SearchResultsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
   

    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var resultsCollectionView: UICollectionView!
    
    var outlets: [Outlet] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return outlets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let resultsCell = resultsCollectionView.dequeueReusableCell(withReuseIdentifier: "searchResultsCell", for: indexPath) as! SearchResultsCollectionViewCell
        
        resultsCell.outletBannerImage.sd_setImage(with:URL(string: outlets[indexPath.item].outletBannerImage!) , placeholderImage: UIImage(named: "iu-2"), options:  [.avoidAutoSetImage , .progressiveDownload])
        resultsCell.outletName.text = outlets[indexPath.item].outletName
        
        return resultsCell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapsOutletSegue" {
            let vc = segue.destination as! OutletDetailViewController
            let outletSelected = sender as? SearchResultsCollectionViewCell
            
            vc._outletName =  outletSelected?.outletName.text!
            if let cell = sender as? SearchResultsCollectionViewCell {
                if let indexPath = resultsCollectionView.indexPath(for: cell) {
                    vc._outletSlug = outlets[indexPath.item].outletSlug
                }
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
