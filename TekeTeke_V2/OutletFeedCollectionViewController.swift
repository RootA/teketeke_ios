//
//  OutletFeedCollectionViewController.swift
//  TekeTeke_V2
//
//  Created by Antony Mwathi on 16/09/2017.
//  Copyright © 2017 Antony Mwathi. All rights reserved.
//

import UIKit

private let reuseIdentifier = "map_feed"

class OutletFeedCollectionViewController: UICollectionViewController {

    var outlets: [Outlet] = []
    @IBOutlet weak var outletCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
          navigationController?.navigationBar.tintColor = UIColor.init(red: 255/255, green: 0/255, blue: 128/255, alpha: 1)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.outletCollectionView.register(UICollectionView.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.outletCollectionView.delegate = self
        self.outletCollectionView.dataSource = self

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
        return outlets.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "map_feed", for: indexPath) as! OutletFeedCellCollectionViewCell
        
        cell.outletName.text = outlets[indexPath.row].outletName
        cell.outletCaption.text = outlets[indexPath.row].outletCaption
        cell.outletBannerImage.sd_setImage(with: URL(string: outlets[indexPath.row].outletBannerImage!), placeholderImage: UIImage(named: ""), options: [.avoidAutoSetImage , .progressiveDownload])
    
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapsOutletSegue" {
            let vc = segue.destination as! OutletDetailViewController
            let outletSelected = sender as? OutletFeedCellCollectionViewCell
            
            vc._outletName =  outletSelected?.outletName.text!
            vc._outletCaption = outletSelected?.outletCaption.text!
            if let cell = sender as? OutletFeedCellCollectionViewCell {
                if let indexPath = outletCollectionView.indexPath(for: cell) {
                    vc._outletSlug = outlets[indexPath.item].outletSlug
                }
            }
            
        }
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
