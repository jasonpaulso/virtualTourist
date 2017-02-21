//
//  CollectionViewController.swift
//  VT
//
//  Created by Jason Southwell on 2/18/17.
//  Copyright © 2017 Jason Southwell. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

private let reuseIdentifier = "collectionViewCell"

class CollectionViewController: UICollectionViewController {
    
    let coordinates = [(36.1540,95.9928), (37.7749,122.4194), (59.3293,18.0686)]
    
    var currentPin: Pin?
    var pins: [Pin] = []
    var photos: [Photo] = []
    var managedContext = getContext()
    
    let flickrHandler = FlickrHandler()
    
    @IBOutlet var photosCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        flickrHandler.currentPin = currentPin
        
        flickrHandler.getPinPhotos(completionHandlerForConvertData: { result, error in
            
            photos = result!
            
            self.photosCollectionView.reloadData()
        
        })
        
        
//        fetchPins()
        
//        let randomIndex = Int(arc4random_uniform(UInt32(coordinates.count)))
        
//        storePin(latitude: coordinates[randomIndex].0, longitude: coordinates[randomIndex].1)
        
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        
        let photo = photos[indexPath.row]
        
        if photo.photo != nil {
            
            let image = UIImage(data: photo.photo! as Data)
            
            cell.imageView?.image = image
            
        }
        
        return cell
    }
    
    
}

