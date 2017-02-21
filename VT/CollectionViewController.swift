//
//  CollectionViewController.swift
//  VT
//
//  Created by Jason Southwell on 2/18/17.
//  Copyright © 2017 Jason Southwell. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

private let reuseIdentifier = "collectionViewCell"

class CollectionViewController: UICollectionViewController {
    
    let coordinates = [(36.1540,95.9928), (37.7749,122.4194), (59.3293,18.0686)]
    
    var currentPin: Pin?
    var pins: [Pin] = []
    var photos: [Photo] = []
    var managedContext = getContext()
    
    let flickrHandler = FlickrHandler()
    
    @IBOutlet var photosCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
//        fetchPins()
        
        let randomIndex = Int(arc4random_uniform(UInt32(coordinates.count)))
        
        storePin(latitude: coordinates[randomIndex].0, longitude: coordinates[randomIndex].1)
        
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        
        let photo = photos[indexPath.row]
        
        if photo.photo != nil {
            
            let image = UIImage(data: photo.photo! as Data)
            
            cell.imageView?.image = image
            
        }
        
        return cell
    }
    
    
}

// Mark Flickr Handling

extension CollectionViewController {
    
    fileprivate func bboxString(latitude: Double, longitude: Double) -> String {
        
        let latitude = latitude
        let longitude = longitude
        let minimumLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
        let minimumLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
        let maximumLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
        let maximumLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    fileprivate func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        let APIScheme = "https"
        let APIHost = "api.flickr.com"
        let APIPath = "/services/rest"
        
        var components = URLComponents()
        components.scheme = APIScheme
        components.host = APIHost
        components.path = APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    
}

// Mark Data Handling

extension  CollectionViewController {
    
    func storePin(latitude: Double, longitude: Double){
        
        let pin = Pin(context: managedContext)
        
        let latitude = latitude
        
        let longitude = longitude
        
        pin.latitude = latitude
        
        pin.longitude = longitude
        
        do {
            try managedContext.save()
            
            self.currentPin = pin
            
            flickrHandler.currentPin = self.currentPin

            flickrHandler.taskForGETImagesByPin(completionHandlerForImageData: {result, _ in
                
                self.flickrHandler.getPinPhotos(completionHandlerForConvertData: {result,_ in
                    
                    self.photos = result!
                    
                    self.photosCollectionView.reloadData()
                    
                })
            })
            
            
        } catch let error as NSError  {
            
            print("Could not save \(error), \(error.userInfo)")
            
        }
    }
    
    func fetchPins() {
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            
            if results.count > 0 {
                
                pins = results
                
                currentPin = pins.first
                
                self.flickrHandler.getPinPhotos(completionHandlerForConvertData: { result, _ in
                    
                    self.photos = result!
                    
                    self.photosCollectionView.reloadData()
                
                })
            }
        } catch let error as NSError {
            
            print("Fetch error: \(error) description: \(error.userInfo)")
            
        }
        
    }
    
    
//    func storePhotoByPin(passedPhoto: [String: AnyObject], passedPin: Pin) {
//        
//        let photo = Photo(context: managedContext)
//        
//        photo.url = (passedPhoto["url_m"] as! String)
//        
//        photo.text = (passedPhoto["title"] as! String)
//        
//        photo.photo = NSData(contentsOf: URL(string: photo.url!)!)
//        
//        passedPin.addToPhotos(photo)
//        
//        do {
//            try managedContext.save()
//            
//            print(passedPin.photos?.count as Any)
//            
//            photosCollectionView?.reloadData()
//            
//        } catch let error as NSError {
//            
//            print("Save error: \(error), description: \(error.userInfo)")
//            
//            
//        }
//    }
//    
//    
//    
//    func getPinPhotos() {
//        
//        if let retrievedPin = managedContext.object(with: (currentPin?.objectID)!) as? Pin {
//            
//            photos = retrievedPin.photos?.array as! [Photo]
//            
//            self.photosCollectionView.reloadData()
//            
//        }
//            
//        else {
//            
//            print("Can't find object.")
//            
//        }
//        
//    }
    
}

// MARK Networking

extension CollectionViewController {
    
//    func taskForGETImagesByPin(pin: Pin) {
//        
//        let methodParameters = [
//            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
//            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
//            Constants.FlickrParameterKeys.BoundingBox: bboxString(latitude: pin.latitude, longitude: pin.longitude),
//            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
//            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
//            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
//            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback,
//            Constants.FlickrParameterKeys.PerPage: "25"
//        ]
//        
//        let url = flickrURLFromParameters(methodParameters as [String : AnyObject])
//        
//        Alamofire.request(url).responseJSON { response in
//            
//            if let status = response.response?.statusCode {
//                switch(status){
//                case 200:
//                    print("success")
//                default:
//                    print("error with response status: \(status)")
//                }
//            }
//            
//            if let result = response.result.value {
//                let JSON = result as! NSDictionary
//                
//                guard let photosDictionary = JSON[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
//                    print("Cannot find key '\(Constants.FlickrResponseKeys.Photos)' in \(JSON)")
//                    return
//                }
//                
//                /* GUARD: Is the "photo" key in photosDictionary? */
//                guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
//                    print("Cannot find key '\(Constants.FlickrResponseKeys.Photo)' in \(photosDictionary)")
//                    return
//                }
//                
//                for photo in photosArray {
//                    self.storePhotoByPin(passedPhoto: photo, passedPin: pin)
//                }
//                
//                self.getPinPhotos()
//                
//            }
//            
//            
//        }
//        
//    }
//    
    
}
