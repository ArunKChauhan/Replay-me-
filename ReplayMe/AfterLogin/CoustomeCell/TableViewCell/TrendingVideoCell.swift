//
//  TrendingVideoCell.swift
//  ReplayMe
//
//  Created by Krishna on 20/05/20.
//  Copyright © 2020 Core Techies. All rights reserved.
//

import UIKit

protocol CollectionViewCellDelegates: class {
    func collectionView(collectionviewcell: TrendingVideoCollectionCell?, index: Int, didTappedInTableViewCell: TrendingVideoCell)
    // other delegate methods that you can define to perform action in viewcontroller
}

class TrendingVideoCell: UITableViewCell {
    weak var cellDelegate: CollectionViewCellDelegates?
     var rowWithData: [CollectionViewCellModel]?
    
    @IBOutlet var titileLbl: UILabel!
     @IBOutlet var totalVideoCount: UILabel!
     @IBOutlet var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
        //self.subCategoryLabel.textColor = UIColor.white
        collectionView.backgroundColor = .clear
        // TODO: need to setup collection view flow layout
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 150, height: 150)
        flowLayout.minimumLineSpacing = 10.0
        flowLayout.minimumInteritemSpacing = 10.0
        self.collectionView.collectionViewLayout = flowLayout
        self.collectionView.showsHorizontalScrollIndicator = false
        
        // Comment if you set Datasource and delegate in .xib
        self.collectionView.dataSource = self as UICollectionViewDataSource
        self.collectionView.delegate = self as UICollectionViewDelegate
        
        // Register the xib for collection view cell
        let cellNib = UINib(nibName: "TrendingVideoCollectionCell", bundle: nil)
        self.collectionView.register(cellNib, forCellWithReuseIdentifier: "collectionviewcellid")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension TrendingVideoCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // The data we passed from the TableView send them to the CollectionView Model
    func updateCellWith(row: [CollectionViewCellModel]) {
           self.rowWithData = row
           self.collectionView.reloadData()
       }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? TrendingVideoCollectionCell
        print("I'm tapping the \(indexPath.item)")
        self.cellDelegate?.collectionView(collectionviewcell: cell, index: indexPath.item, didTappedInTableViewCell: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.rowWithData?.count ?? 0
        // return 5
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // Set the data for each cell (color and color name)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionviewcellid", for: indexPath) as? TrendingVideoCollectionCell {
            //cell.contentLbl.text = self.rowWithData?[indexPath.item].content ?? ""
      // let totalViews  =   self.rowWithData?[indexPath.item].views ?? ""
              // cell.totalViewLbl.text = "\(totalViews) views"
            cell.backgroundColor = .clear
       let videoScreenShotUrl  =    self.rowWithData?[indexPath.item].videoScreenShotUrl ?? ""
            cell.videoThumbImg.sd_setImage(with: URL(string: videoScreenShotUrl), placeholderImage: UIImage(named: "layer35"))
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    // Add spaces at the beginning and the end of the collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
}
