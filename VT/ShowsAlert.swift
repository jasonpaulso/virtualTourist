//
//  ShowsAlert.swift
//  VirtualTourist
//
//  Created by Jason Southwell on 2/24/17.
//  Copyright © 2017 Jason Southwell. All rights reserved.
//

import Foundation
import UIKit
import CoreData

let appDelegate = UIApplication.shared.delegate as? AppDelegate

protocol ShowsAlert {}

extension ShowsAlert where Self: UIViewController {

    func showDeleteAlert(passedPhoto: Photo) {

        if !(passedPhoto.isFavorite) {

            appDelegate?.persistentContainer.viewContext.delete(passedPhoto)

            appDelegate?.saveContext()

            self.dismiss(animated: true, completion: nil)

        } else {

            let alertController = UIAlertController(title: "Alert", message: "This photo will also be removed from your favorites.", preferredStyle: .alert)

            let deleteFromFavoriteAction = UIAlertAction(title: "OK", style: .destructive, handler: {_ in

                passedPhoto.isFavorite = false

                PhotoPinModelHandler().deleteSelectedImage(photo: passedPhoto)

                alertController.dismiss(animated: true, completion: nil)

                self.dismiss(animated: true, completion: nil)

            })

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
                alertController.dismiss(animated: true, completion: {

                })})

            alertController.addAction(deleteFromFavoriteAction)
            
            alertController.addAction(cancelAction)

            present(alertController, animated: true, completion: nil)

        }

    }
    
    func showEmptyCollectionAlert() {
        
        let alert = UIAlertController(title: "No Photos", message: "Unfortunately there are no photos available for this location.", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in
            
            _ = self.navigationController?.popToRootViewController(animated: true)
            
        })
        
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    

}
