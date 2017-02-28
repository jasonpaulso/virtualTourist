//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Jason Southwell on 2/22/17.
//  Copyright © 2017 Jason Southwell. All rights reserved.
//

import UIKit
import CoreData
import BSGridCollectionViewLayout


private let reuseIdentifier = "collectionViewCell"

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, ShowsAlert {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    var context: NSManagedObjectContext?

    @IBOutlet var reloadLabel: UILabel!

    @IBOutlet var favoritesLabel: UILabel!

    @IBOutlet var reloadButton: UIToolbar!
    @IBOutlet var collectionView: UICollectionView!

    @IBAction func loadMore(_ sender: Any) {

        reloadImageCollection()

    }

    @IBAction func deletePinAction(_ sender: Any) {

        context?.delete(currentPin!)

        appDelegate.saveContext()

        _ = navigationController?.popToRootViewController(animated: true)

    }
    
    
    @IBOutlet var reloadButtonOutlet: UIBarButtonItem!
    
    @IBOutlet weak var deletePinButtonOutlet: UIBarButtonItem!
    
    override func viewDidLoad() {

        context = appDelegate.persistentContainer.viewContext

        if traitCollection.forceTouchCapability == .available {

            registerForPreviewing(with: self, sourceView: self.collectionView)

        }

        self.title = passedTitle ?? currentPin?.name

        super.viewDidLoad()

        collectionView.delegate = self

        collectionView.dataSource = self

        loadPhotoData()
        
        setUpLongPress()

        if predicate != nil && (fetchedResultsController?.fetchedObjects?.count)! < 1 {

            favoritesLabel.text = "You don't have any favorites yet. You can add to your favorites using Peek & Pop in the main image galleries."
            
        } else {

            favoritesLabel.isHidden = true
            favoritesLabel.text = "There is nothing more to see here. Go out and explore!"
            
        }
        
        if (fetchedResultsController?.fetchedObjects!.count)! < 1 {
            self.setUpEmptyCollectionView()
            
        }
        
        if predicate != nil {
            
            reloadButtonOutlet.isEnabled = false
            deletePinButtonOutlet.isEnabled = false
            
        } else if Int16(flickrHandler.page) == (currentPin?.numberOfPages)! {
            
            self.reloadLabel.isHidden = true
            reloadButtonOutlet.isEnabled = false
            
        } else if (fetchedResultsController?.fetchedObjects?.count)! > 1 {
            
            startCallToActionTimer()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(didRotate(notification:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    
    func didRotate(notification: NSNotification)
    {
        collectionView.reloadData()
    }




    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?

    let flickrHandler = FlickrHandler()

    var currentPin: Pin?

    var timer: Timer?

    var timerCounter = 0

    var passedTitle: String?

    var refreshControl = UIRefreshControl()

    var bounceCounter = 0

    private func incrementBounceCounter() -> Bool {
        
        bounceCounter += 1

        if bounceCounter == 3 {
            return false
        }

        return true
    }
    
    func setUpEmptyCollectionView() {
        
        self.collectionView.willRemoveSubview(refreshControl)
        
        if timer != nil {
            
            timer?.invalidate()
        }
        
        favoritesLabel.isHidden = false
        
//        reloadButtonOutlet.isEnabled = false
    
    }

    private func startCallToActionTimer() {

        self.createRefreshControl()

    }

    private func setUpLongPress() {

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

    private func createRefreshControl() {

        refreshControl = UIRefreshControl()

        refreshControl.attributedTitle = NSAttributedString(string: " ↓ refreshing ↓ ")

        refreshControl.addTarget(self, action: #selector(refreshStream), for: .valueChanged)

        collectionView!.addSubview(refreshControl)
    }

    @objc private func refreshStream() {

        reloadImageCollection()

    }

    private func reloadImageCollection() {
        reloadLabel.isHidden = true

        reloadButtonOutlet.isEnabled = false

        flickrHandler.loadMorePhotos(currentPin: currentPin!, withCompletion: { _, error in

            DispatchQueue.main.async {
                if error == nil {

                    self.reloadLabel.isHidden = false
                    self.reloadButtonOutlet.isEnabled = true
                    self.refreshControl.endRefreshing()
                    
                    if (self.fetchedResultsController?.fetchedObjects!.count)! < 1 {
                        
                        self.setUpEmptyCollectionView()
                    }

                }
            }

        })
    }

    override func viewDidDisappear(_ animated: Bool) {

        if timer != nil {

            timer?.invalidate()

        }

    }

    var predicate: NSPredicate?

    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        let section = self.fetchedResultsController?.sections![section]
        
        return section!.numberOfObjects

    }

    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CollectionViewCell

        cell?.configureIntialCell()

        configureCell(cell: cell!, atIndexPath: indexPath as NSIndexPath)

        return cell!
    }

    private func configureCell(cell: CollectionViewCell, atIndexPath indexPath: NSIndexPath) {

        let photo = self.fetchedResultsController?.object(at: indexPath as IndexPath) as? Photo

        if photo?.photo != nil {

            cell.imageView!.image = UIImage(data: photo!.photo! as Data)

            cell.activityIndicator.stopAnimating()

        } else {

            flickrHandler.downloadImageData(photo: photo!)
        }

    }

    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let photo = fetchedResultsController?.fetchedObjects?[indexPath.row] as? Photo

        showDeleteAlert(passedPhoto: photo!)

    }

}
