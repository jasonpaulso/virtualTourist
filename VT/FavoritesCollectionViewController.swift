//
//  FavoritesCollectionViewController.swift
//  VT
//
//  Created by Jason Southwell on 2/22/17.
//  Copyright © 2017 Jason Southwell. All rights reserved.
//

import UIKit
import CoreData
import BSGridCollectionViewLayout

private let reuseIdentifier = "favoriteCollectionCell"

class FavoritesCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate
{
    
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.delegate = self
        collectionView?.dataSource = self
        
        let layout = GridCollectionViewLayout()
        layout.itemsPerRow = 3
        layout.itemSpacing = 2
        layout.itemHeightRatio = 3/4
        
        collectionView?.collectionViewLayout = layout
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(viewPhotoDetail))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.collectionView?.addGestureRecognizer(lpgr)
        loadData()

    }
    
    func photosFetchRequest() -> NSFetchRequest<NSFetchRequestResult> {

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        let predicate = NSPredicate(format:"isFavorite = true")
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = predicate
        return fetchRequest
    }

    func loadData() {
        print("here 3")
        fetchedResultsController = NSFetchedResultsController(fetchRequest: photosFetchRequest(), managedObjectContext: getContext(), sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
            
            
        } catch  {
            
            print("Cannot open photos")
            
        }
        
    }



    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        let section = self.fetchedResultsController?.sections![section]
        
        if (section?.numberOfObjects)! > 0 {
            
            return section!.numberOfObjects
            
        }
        
        return 0
        

    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FavoritesCollectionViewCell
        
        let favorite = fetchedResultsController?.fetchedObjects?[indexPath.row] as! Photo
        
        let photo = favorite.photo
        
        
        cell.imageView?.image = UIImage(data: photo! as Data)
    
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        openInImageView(indexPath: indexPath)
    }

}

extension FavoritesCollectionViewController {
    
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
        
        collectionView?.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                
                self.collectionView?.insertItems(at: [((indexPath as IndexPath) as IndexPath)])
                
            }
            
            for indexPath in self.deletedIndexPaths {
                
                self.collectionView?.deleteItems(at: [((indexPath as IndexPath) as IndexPath)])
                
            }
            
            for indexPath in self.updatedIndexPaths {
                
                self.collectionView?.reloadItems(at: [indexPath as IndexPath])
                
            }
            
        }, completion: nil)
    }
    
    func viewPhotoDetail(gestureReconizer: UILongPressGestureRecognizer) {
        
        if gestureReconizer.state != UIGestureRecognizerState.ended {
            return
        }
        
        let p = gestureReconizer.location(in: self.collectionView)
        
        let indexPath = self.collectionView?.indexPathForItem(at: p)
        
        if indexPath != nil {
            
            openInImageView(indexPath: indexPath!)
            
        } else {
            
            print("Could not find index path")
            
        }
    }
    
    func openInImageView(indexPath: IndexPath) {
        
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "imageViewController") as! ImageViewController
        
        viewController.selectedImage = fetchedResultsController?.fetchedObjects?[(indexPath.row)] as? Photo
        
        viewController.modalPresentationStyle = .overCurrentContext
        
        present(viewController, animated: true, completion: nil)
    }
    
}


