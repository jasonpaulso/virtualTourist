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

class ImageViewController: UIViewController {
    
    var selectedImage: Photo?
    
    @IBOutlet weak var imageScrollView: ImageScrollView!

    @IBAction func closeModalAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        imageView.image = selectedImage
        let photo = selectedImage!
        let image = UIImage(data: photo.photo! as Data)
        
        let screenSize: CGRect = UIScreen.main.bounds
        imageScrollView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.width)
        imageScrollView.display(image: image!)
    
        // Do any additional setup after loading the view.
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBOutlet var imageView: UIImageView!
    
    @IBAction func deleteImageAction(_ sender: Any) {
        deleteAction()
    }
    
    func deleteAction() {
        
        let collectionView = CollectionViewController()
        
        if !(selectedImage?.isFavorite)! {
            collectionView.deleteSelectedImage(photo: selectedImage!)
            self.dismiss(animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "Alert", message: "This photo will also be removed from your favorites.", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .destructive, handler: {action in
                collectionView.deleteSelectedImage(photo: self.selectedImage!)
                self.dismiss(animated: true, completion: nil)})
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {action in
                alertController.dismiss(animated: true, completion: nil)})
            alertController.addAction(alertAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        }
        
    }
    @IBAction func favoritePhotoAction(_ sender: Any) {
        
        addToFavorites()
        
        let alertController = UIAlertController(title: nil, message: "Added to your favorites!", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: {
            action in
            alertController.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
        
        
        
    }
    
    func addToFavorites() {
        
        selectedImage?.isFavorite = true
        
        do {
            try getContext().save()
            
            print("favorited!")
            
        } catch  {
            
            print("Cannot favorite photo")
            
        }
        
        
    }
    
    override var previewActionItems : [UIPreviewActionItem] {
        
        let favoriteAction = UIPreviewAction(title: "Like", style: .default) { (action, viewController) -> Void in
            self.addToFavorites()
        }
        
        let deleteAction = UIPreviewAction(title: "Delete", style: .destructive) { (action, viewController) -> Void in
            self.deleteAction()
        }
        
        return [favoriteAction, deleteAction]
        
    }

}


