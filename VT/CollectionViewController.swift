//
//  ViewController.swift
//  VT
//
//  Created by Jason Southwell on 2/22/17.
//  Copyright © 2017 Jason Southwell. All rights reserved.
//

import UIKit
import CoreData
import BSGridCollectionViewLayout
import SimpleAnimation

private let reuseIdentifier = "collectionViewCell"


class CollectionViewController: UIViewController, UICollectionViewDelegate, NSFetchedResultsControllerDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate, UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {

        let indexPath = collectionView?.indexPathForItem(at: location)
        
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "imageViewController") as! ImageViewController
        
        let cell = (collectionView?.cellForItem(at: indexPath!)) as? CollectionViewCell
        
        print(cell?.imageView.image as Any)
            
        viewController.selectedImage = fetchedResultsController?.fetchedObjects?[(indexPath?.row)!] as? Photo
        
        print(viewController.selectedImage as Any)
            
        viewController.modalPresentationStyle = .overCurrentContext
            
        previewingContext.sourceRect = (cell?.frame)!
        
        return viewController
        
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
 
        present(viewControllerToCommit, animated: true, completion: nil)
    }
    
    @IBOutlet var reloadLabel: UILabel!
    
    
    var hasLoadedOnce = false
    
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    let flickrHandler = FlickrHandler()
    
    var currentPin: Pin?
    
    var page = 1
    
    @IBOutlet var reloadButton: UIButton!
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBAction func loadMore(_ sender: Any) {
        
        loadMorePhotos()
        
    }
    
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        
        if (traitCollection.forceTouchCapability == .available) {
            
            registerForPreviewing(with: self, sourceView: collectionView)
            
        }
        
        
        super.viewDidLoad()
        
        collectionView.delegate = self
        
        collectionView.dataSource = self
        
        flickrHandler.currentPin = currentPin
        
        loadData()
        
        let layout = GridCollectionViewLayout()
        layout.itemsPerRow = 3
        layout.itemSpacing = 2
        layout.itemHeightRatio = 3/4
        
        collectionView?.collectionViewLayout = layout
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(viewPhotoDetail))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.collectionView.addGestureRecognizer(lpgr)

        
    }
    
    func createRefreshControl() {
   
        refreshControl = UIRefreshControl()
        
        refreshControl.attributedTitle = NSAttributedString(string: " ↓ refreshing ↓ ")
        
        refreshControl.addTarget(self, action: #selector(refreshStream), for: .valueChanged)
        
        collectionView!.addSubview(refreshControl)
    }
    
    func refreshStream(){
        
        reloadLabel.isHidden = true

        loadMorePhotos()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            
            self.refreshControl.endRefreshing()
            self.reloadLabel.isHidden = false
            
        }

    }
    
    func viewPhotoDetail(gestureReconizer: UILongPressGestureRecognizer) {
        
        if gestureReconizer.state != UIGestureRecognizerState.ended {
            return
        }
        
        let p = gestureReconizer.location(in: self.collectionView)
        
        let indexPath = self.collectionView.indexPathForItem(at: p)
        
        if indexPath != nil {
            
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "imageViewController") as! ImageViewController
            
            viewController.selectedImage = fetchedResultsController?.fetchedObjects?[(indexPath?.row)!] as? Photo
            
            viewController.modalPresentationStyle = .overCurrentContext
            
            present(viewController, animated: true, completion: nil)
            
        } else {
            
            print("Could not find index path")
            
        }
    }
    
    
    func photosFetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        
        let predicate = NSPredicate(format: "pin == %@", self.currentPin!)
        
        fetchRequest.predicate = predicate
        
        fetchRequest.sortDescriptors = []
        
        return fetchRequest
    }
    
    func loadData() {
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: photosFetchRequest(), managedObjectContext: getContext(), sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController?.delegate = self
        
        do {
            
            try fetchedResultsController?.performFetch()
            
            self.createRefreshControl()

            
        } catch  {

            
            print(error)
            
        }
        
        
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let section = self.fetchedResultsController?.sections![section]
        
        return section!.numberOfObjects
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        
        cell.activityIndicator.center = cell.center
        
        cell.activityIndicator.hidesWhenStopped = true
        
        cell.addSubview(cell.activityIndicator)
        
        cell.activityIndicator.startAnimating()
        
        DispatchQueue.main.async {
            
            self.configureCell(cell: cell, atIndexPath: indexPath as NSIndexPath)
            
        }
        
        return cell
    }
    
    func configureCell(cell: CollectionViewCell, atIndexPath indexPath: NSIndexPath) {
        
        DispatchQueue.main.async {

            print("called")
            
            let photo = self.fetchedResultsController?.object(at: indexPath as IndexPath) as! Photo

            cell.imageView!.image = UIImage(data: photo.photo! as Data)
            
            cell.activityIndicator.stopAnimating()
 
            cell.tintColor = .clear
            
        }
    }
    
    
 
    

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let photo = fetchedResultsController?.fetchedObjects?[indexPath.row] as! Photo
        
        deleteSelectedImage(photo: photo)
        
    }
    
    func deleteSelectedImage(photo: Photo) {
        
        getContext().delete(photo)
        
        do {
            try getContext().save()
            
            
        } catch  {
            
            print("Cannot delete photo")
            
        }
    }
    
    @IBOutlet var pinName: UILabel!
    
    
    func loadMorePhotos() {
        
//        deleteRefreshControl()
        
        page += 1
        
        currentPin?.photos = nil
        
        do {
            
            try getContext().save()
            
            
        } catch  {
            
            print("Cannot delete photo")
            
            return
        }
        
        
        self.flickrHandler.taskForGETImagesByPin(page: page, completionHandlerForImageData: {_, _ in

            
        })
        
        
        
    }
    
}

extension CollectionViewController {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        insertedIndexPaths = [NSIndexPath]()
        
        deletedIndexPaths = [NSIndexPath]()
        
        updatedIndexPaths = [NSIndexPath]()
        
    }
    
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        
        switch type {
            
        case .insert:
            
            insertedIndexPaths.append(newIndexPath! as NSIndexPath)
            
            break
            
        case .delete:
            
            deletedIndexPaths.append(indexPath! as NSIndexPath)
            
            break
            
        case .update:
            
            updatedIndexPaths.append(indexPath! as NSIndexPath)
            
            break
            
        default:
            
            break
            
        }

    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        collectionView.performBatchUpdates({() -> Void in
            
            
            for indexPath in self.insertedIndexPaths {
                
                self.collectionView.insertItems(at: [indexPath as IndexPath])
                
            }
            
            for indexPath in self.deletedIndexPaths {
                
                self.collectionView.deleteItems(at: [indexPath as IndexPath])
                
            }
            
            for indexPath in self.updatedIndexPaths {
                
                self.collectionView.reloadItems(at: [indexPath as IndexPath])
                
            }
            
        }, completion: { bool in
            
            if bool {
                self.collectionView.hop(toward: .bottom, amount: 0.15, duration: 4.0, delay: 1.0, completion: nil)
            }
            
            
            
//            if !UserDefaults.standard.bool(forKey: "loadedOnce") && bool {
//                UserDefaults.standard.setValue(true, forKey: "loadedOnce")
//                self.hasLoadedOnce = true
//                self.collectionView.hop(toward: .bottom, amount: 0.15, duration: 4.0, delay: 1.0, completion: nil)
//
//            }
            
            
        })
    }
    
}


