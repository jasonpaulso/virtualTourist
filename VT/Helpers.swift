//
//  Helpers.swift
//  VT
//
//  Created by Jason Southwell on 2/24/17.
//  Copyright © 2017 Jason Southwell. All rights reserved.
//

import Foundation
import UIKit
import CoreData


public func getContext() -> NSManagedObjectContext {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    return appDelegate.persistentContainer.viewContext
}


protocol ShowsAlert {}

extension ShowsAlert where Self: UIViewController {
    
    func showDeleteAlert(passedPhoto: Photo) {
        
        
        if !(passedPhoto.isFavorite) {
            
            getContext().delete(passedPhoto)
            
            do {
                try getContext().save()
                
                
            } catch  {
                
                print("Cannot delete photo")
                
            }
            
            
        } else {
            
            let alertController = UIAlertController(title: "Alert", message: "This photo will also be removed from your favorites.", preferredStyle: .alert)
            
            let alertAction = UIAlertAction(title: "OK", style: .destructive, handler: {action in
                
                passedPhoto.isFavorite = false
                
                PhotoPinModelHandler().deleteSelectedImage(photo: passedPhoto)
                
                alertController.dismiss(animated: true, completion: nil)
                
                self.dismiss(animated: true, completion: nil)
                
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {action in
                alertController.dismiss(animated: true, completion: {
                    
                })})
            
            alertController.addAction(alertAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
            
            
        }
        
    }
    
    
    
}
