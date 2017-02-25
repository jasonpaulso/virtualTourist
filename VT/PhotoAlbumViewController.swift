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


class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, ShowsAlert {
    
    @IBOutlet var reloadLabel: UILabel!

    @IBOutlet var favoritesLabel: UILabel!
    
    @IBOutlet var reloadButton: UIButton!
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBAction func loadMore(_ sender: Any) {
        
        flickrHandler.loadMorePhotos(currentPin: currentPin!)
        
    }
    
    let downloadManager = DownloadManager()
    
    override func viewDidLoad() {
        


        
//        for photo in (fetchedResultsController?.fetchedObjects as! [Photo]) {
//            downloadManager.addDownload(URL(string:photo.url!)!)
//        }

        
        
        
        if (traitCollection.forceTouchCapability == .available) {
            
            registerForPreviewing(with: self, sourceView: collectionView)
            
        }
        
        self.title = passedTitle ?? currentPin?.name
        
        super.viewDidLoad()
        
        collectionView.delegate = self
        
        collectionView.dataSource = self
        
        flickrHandler.currentPin = currentPin
        
        loadPhotoData()
        
        setUpLongPress()
        
        if predicate != nil {
            
            reloadButton.isHidden = true
            
            
        } else {
            
            startCallToActionTimer()
            
        }
        
        if predicate != nil && fetchedResultsController?.fetchedObjects?.count == 0 {
            
            favoritesLabel.text = "You don't have any favorites yet. You can add to your favorites using Peek & Pop in the main image galleries."
        } else {
            
            favoritesLabel.text = nil
            
        }

    }

    
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    let flickrHandler = FlickrHandler()
    
    var currentPin: Pin?
    
    var timer: Timer!
    
    var timerCounter = 0
    
    var passedTitle: String?
    
    var refreshControl = UIRefreshControl()
    
    private func startCallToActionTimer() {
        
        self.createRefreshControl()
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 180, repeats: true, block: { _ in
            
            self.collectionView.hop(toward: .bottom, amount: 0.15, duration: 4.0, delay: 1.0, completion: { _ in})
        })
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
    
    @objc private func refreshStream(){
        
        reloadLabel.isHidden = true

        flickrHandler.loadMorePhotos(currentPin: currentPin!)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            
            self.refreshControl.endRefreshing()
            self.reloadLabel.isHidden = false
            
        }

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        if timer != nil {
            
            timer.invalidate()
            
        }
        
        
    }
    
    
    var predicate: NSPredicate?

    
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let section = self.fetchedResultsController?.sections![section]
        
        return section!.numberOfObjects
        
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

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
    
    private func configureCell(cell: CollectionViewCell, atIndexPath indexPath: NSIndexPath) {
        
        DispatchQueue.main.async {

            let photo = self.fetchedResultsController?.object(at: indexPath as IndexPath) as! Photo
        
        if photo.photo != nil {
        
            cell.imageView!.image = UIImage(data: photo.photo! as Data)
            
            cell.activityIndicator.stopAnimating()
            
            cell.tintColor = .clear
            
        } else {
            
            cell.imageView.image = #imageLiteral(resourceName: "Smiley")
            
        }

        }

        
    }
    
    
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let photo = fetchedResultsController?.fetchedObjects?[indexPath.row] as! Photo

        showDeleteAlert(passedPhoto: photo)
        
    }
    
    
}


