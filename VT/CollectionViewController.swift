////
////  CollectionViewController.swift
////  VT
////
////  Created by Jason Southwell on 2/18/17.
////  Copyright © 2017 Jason Southwell. All rights reserved.
////
//
//import UIKit
//import CoreData
//import Alamofire
//
//private let reuseIdentifier = "collectionViewCell"
//
//class CollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate {
//    
//    var currentPin: Pin?
//    
////    lazy var photos: [Photo] = []
//    
//    let flickrHandler = FlickrHandler()
//    
//    @IBOutlet var photosCollectionView: UICollectionView!
//    
////    @IBOutlet var photosCollectionView: UICollectionView!
//    
//    var fetchedResultsController: NSFetchedResultsController<Pin>!
//    
//    override func viewDidLoad() {
//        
//        super.viewDidLoad()
//        
////        collectionView?.delegate = self
//        
//        flickrHandler.currentPin = currentPin
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(reloadCollectionView), name:NSNotification.Name(reloadNotification), object: nil)
//        
//        
//    }
//    
//    var cells: Int?
//    
//    func reloadCollectionView() -> Void {
//        
//        DispatchQueue.main.async {
//
//            self.collectionView?.reloadData()
//            
//        }
//    
//    }
//    
//    @IBOutlet var activityIndicator: UIActivityIndicatorView!
//
//    
//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        
//        return (currentPin?.photos?.count)!
//    }
//    
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
//        let photo = self.currentPin?.photos?[indexPath.row] as! Photo
//        cell.imageView?.image = UIImage(data: photo.photo! as Data)
//        return cell
//    }
//    
//    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        
//        let photo = currentPin?.photos?[indexPath.row] as! Photo
//        
//        getContext().delete(photo)
//        
//        do {
//            try getContext().save()
//            
//            reloadCollectionView()
//            
//        } catch  {
//            
//            print("Cannot delete photo")
//            
//        }
//        
//       
//    }
//    
//    
//    
//    
//}
//
//extension UIImageView {
//    public func imageFromServerURL(urlString: String) {
//        
//        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
//            
//            if error != nil {
//                print(error!)
//                return
//            }
//            DispatchQueue.main.async(execute: { () -> Void in
//                let image = UIImage(data: data!)
//                self.image = image
//            })
//            
//        }).resume()
//    }
//}
//
//
