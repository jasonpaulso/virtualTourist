//
//  ImageViewController.swift
//  VT
//
//  Created by Jason Southwell on 2/22/17.
//  Copyright © 2017 Jason Southwell. All rights reserved.
//

import UIKit
import ImageScrollView
import CoreData

class ImageViewController: UIViewController, ShowsAlert {
    
    @IBOutlet var addToFavoritesButton: UIBarButtonItem!
    
    @IBOutlet weak var imageScrollView: ImageScrollView!
    
    @IBAction func closeModalAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteImageAction(_ sender: Any) {
        deleteAction()
    }
    
    @IBAction func favoritePhotoAction(_ sender: Any) {
        
        setUpFavorite()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpImageScrollView()
        
        self.navigationItem.title = selectedImage?.text
        if (selectedImage?.isFavorite)! {
            addToFavoritesButton.isEnabled = false
        }
    }
    
    var selectedImage: Photo?
    
    var selectedImageTitle: String?
    
    let modelHandler = PhotoPinModelHandler()
    
    private func deleteAction() {
        showDeleteAlert(passedPhoto: selectedImage!)

    }
    
    private func setUpImageScrollView() {
        
        let photo = selectedImage!
        
        let image = UIImage(data: photo.photo! as Data)
        
        let screenSize: CGRect = UIScreen.main.bounds
        imageScrollView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.width)
        imageScrollView.display(image: image!)
        imageScrollView.maximumZoomScale = 5.0
//        imageScrollView.minimumZoomScale = 1.0
        imageScrollView.zoomScale = 1.0

        
    }
    
    private func setUpFavorite() {
    
        modelHandler.addToFavorites(passedPhoto: selectedImage!)
        
        addToFavoritesButton.isEnabled = false
        
        let alertController = UIAlertController(title: nil, message: "Added to your favorites!", preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: {
            action in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    
    }
    
    override var previewActionItems : [UIPreviewActionItem] {
        
        let favoriteAction = UIPreviewAction(title: "Favorite", style: .default) { (action, viewController) -> Void in
            self.modelHandler.addToFavorites(passedPhoto: self.selectedImage!)
        }
        
        let deleteAction = UIPreviewAction(title: "Delete", style: .destructive) { (action, viewController) -> Void in
            self.deleteAction()
        }
        
        return [favoriteAction, deleteAction]
        
    }

}

