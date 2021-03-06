//
//  CollectionViewCell.swift
//  VirtualTourist
//
//  Created by Jason Southwell on 2/18/17.
//  Copyright © 2017 Jason Southwell. All rights reserved.
//

import UIKit
import Alamofire

class CollectionViewCell: UICollectionViewCell {

    @IBOutlet var collectionViewCell: UIImageView!

    @IBOutlet var imageView: UIImageView!

    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)

    func configureIntialCell() {

        imageView.image = #imageLiteral(resourceName: "placeholder")

        activityIndicator.center = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        
        activityIndicator.startAnimating()

        activityIndicator.hidesWhenStopped = true

        addSubview(self.activityIndicator)

    }

}
