//
//  PhotoAlbumViewControllerExtensions.swift
//  VT
//
//  Created by Jason Southwell on 2/24/17.
//  Copyright © 2017 Jason Southwell. All rights reserved.
//

import Foundation
import CoreData
import BSGridCollectionViewLayout
import SimpleAnimation

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    private func photosFetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        
        let predicate = self.predicate ?? NSPredicate(format: "pin == %@", self.currentPin!)
        
        fetchRequest.predicate = predicate
        
        fetchRequest.sortDescriptors = []
        
        return fetchRequest
    }
    
    func loadPhotoData() {
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: photosFetchRequest(), managedObjectContext: getContext(), sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController?.delegate = self
        
        do {
            
            try fetchedResultsController?.performFetch()
            
            if timer != nil {
                
                timer.fire()
                
            }
            
        } catch  {
            
            print(error)
            
        }
        
    }
    
    
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
            
        })
    }
    
}

extension PhotoAlbumViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        let indexPath = collectionView?.indexPathForItem(at: location)
        
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "imageViewController") as! ImageViewController
        
        let cell = (collectionView?.cellForItem(at: indexPath!)) as? CollectionViewCell
        
        viewController.selectedImage = fetchedResultsController?.fetchedObjects?[(indexPath?.row)!] as? Photo
        
        viewController.selectedImageTitle = currentPin?.name
        
        viewController.modalPresentationStyle = .overCurrentContext
        
        previewingContext.sourceRect = (cell?.frame)!
        
        return viewController
        
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        present(viewControllerToCommit, animated: true, completion: nil)
    }
    
}

extension PhotoAlbumViewController: UIGestureRecognizerDelegate {
    
    func viewPhotoDetail(gestureReconizer: UILongPressGestureRecognizer) {
        
        if gestureReconizer.state != UIGestureRecognizerState.ended {
            return
        }
        
        let point = gestureReconizer.location(in: self.collectionView)
        
        let indexPath = self.collectionView.indexPathForItem(at: point)
        
        if indexPath != nil {
            
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "imageViewController") as! ImageViewController
            
            viewController.selectedImage = fetchedResultsController?.fetchedObjects?[(indexPath?.row)!] as? Photo
            
            viewController.modalPresentationStyle = .overCurrentContext
            
            present(viewController, animated: true, completion: nil)
            
        } else {
            
            print("Could not find index path")
            
        }
    }
}

