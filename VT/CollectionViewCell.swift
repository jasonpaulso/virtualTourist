//
//  CollectionViewCell.swift
//  VT
//
//  Created by Jason Southwell on 2/18/17.
//  Copyright © 2017 Jason Southwell. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var collectionViewCell: UIImageView!
    
    @IBOutlet var imageView: UIImageView!
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    
}
