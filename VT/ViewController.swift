//
//  ViewController.swift
//  VT
//
//  Created by Jason Southwell on 2/22/17.
//  Copyright © 2017 Jason Southwell. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

private let reuseIdentifier = "collectionViewCell"

class CollectionViewController: UIViewController, UICollectionViewDelegate, NSFetchedResultsControllerDelegate, UICollectionViewDataSource {
    
    var currentPin: Pin?
    let flickrHandler = FlickrHandler()
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        flickrHandler.currentPin = currentPin
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCollectionView), name:NSNotification.Name(reloadNotification), object: nil)
        
        // Do any additional setup after loading the view.
    }

    func reloadCollectionView() -> Void {
        
        DispatchQueue.main.async {
            
            self.collectionView?.reloadData()
            
        }
        
    }
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return (currentPin?.photos?.count)!
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        let photo = self.currentPin?.photos?[indexPath.row] as! Photo
        cell.imageView?.image = UIImage(data: photo.photo! as Data)
        return cell
    }
    
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let photo = currentPin?.photos?[indexPath.row] as! Photo
        
        getContext().delete(photo)
        
        do {
            try getContext().save()
            
            reloadCollectionView()
            
        } catch  {
            
            print("Cannot delete photo")
            
        }
        
        
    }

    @IBOutlet var collectionView: UICollectionView!


}
