//
//  Structs.swift
//  Virtual Tourist
//
//  Created by Jason Southwell on 2/13/17.
//  Copyright © 2017 Jason Southwell. All rights reserved.
//

import Foundation
import Alamofire
import UIKit
import CoreData


func getContext() -> NSManagedObjectContext {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    return appDelegate.persistentContainer.viewContext
}

class FlickrHandler {
    
    var currentPin: Pin?
    var photos = [Photo]()
    
    let managedContext = getContext()
    
    func storePin(latitude: Double, longitude: Double){
        
        let pin = Pin(context: managedContext)
        
        let latitude = latitude
        
        let longitude = longitude
        
        pin.latitude = latitude
        
        pin.longitude = longitude
        
        do {
            try managedContext.save()
            
            self.currentPin = pin
            
            //            flickerHandler.passedPin = self.currentPin
            //
            //            flickerHandler.taskForGETImagesByPin()
            
//            self.taskForGETImagesByPin()
            
        } catch let error as NSError  {
            
            print("Could not save \(error), \(error.userInfo)")
            
        }
    }
    
    func fetchPins() {
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            
            if results.count > 0 {
                
//                pins = results
//                
//                currentPin = pins.first
                
//                getPinPhotos()
            }
        } catch let error as NSError {
            
            print("Fetch error: \(error) description: \(error.userInfo)")
            
        }
        
    }
    
    
    func storePhotosByPin(passedPhotos: [[String: AnyObject]], passedPin: Pin, completionHandlerForConvertData: (_ result: [Photo]?, _ error: String?) -> Void) {
        
        for passedPhoto in passedPhotos {
            
            let photo = Photo(context: managedContext)
            
            photo.url = (passedPhoto["url_m"] as! String)
            
            photo.text = (passedPhoto["title"] as! String)
            
            photo.photo = NSData(contentsOf: URL(string: photo.url!)!)
            
            passedPin.addToPhotos(photo)
        }
        
        do {
            try managedContext.save()
            
            completionHandlerForConvertData((currentPin?.photos?.array as! [Photo]), nil)
            
            print(currentPin?.photos?.count as Any)
            
//            photosCollectionView?.reloadData()
            
        } catch let error as NSError {
            
            print("Save error: \(error), description: \(error.userInfo)")
            
            
        }
    }
    
    
    
    func getPinPhotos(completionHandlerForConvertData: (_ result: [Photo]?, _ error: String?) -> Void) {
        
        if let retrievedPin = getContext().object(with: (currentPin?.objectID)!) as? Pin {
            
            photos = retrievedPin.photos?.array as! [Photo]
            
            completionHandlerForConvertData(photos, nil)
            
//            self.photosCollectionView.reloadData()
            
        }
            
        else {
            
            print("Can't find object.")
            
        }
        
    }
    
    
    
    // MARK Networking
    
    
    
    func taskForGETImagesByPin(completionHandlerForImageData: @escaping (_ result: [Photo], _ error: String?) -> Void) {
        
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.BoundingBox: bboxString(latitude: (currentPin?.latitude)!, longitude: (currentPin?.longitude)!),
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback,
            Constants.FlickrParameterKeys.PerPage: "25"
        ]
        
        let url = flickrURLFromParameters(methodParameters as [String : AnyObject])
        
        Alamofire.request(url).responseJSON { response in
            
            if let status = response.response?.statusCode {
                switch(status){
                case 200:
                    print("success")
                default:
                    print("error with response status: \(status)")
                }
            }
            
            if let result = response.result.value {
                let JSON = result as! NSDictionary
                
                guard let photosDictionary = JSON[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                    print("Cannot find key '\(Constants.FlickrResponseKeys.Photos)' in \(JSON)")
                    return
                }
                
                /* GUARD: Is the "photo" key in photosDictionary? */
                guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                    print("Cannot find key '\(Constants.FlickrResponseKeys.Photo)' in \(photosDictionary)")
                    return
                }
                
                self.storePhotosByPin(passedPhotos: photosArray, passedPin: self.currentPin!, completionHandlerForConvertData: {result,_ in
                
                    completionHandlerForImageData(result!, nil)
                
                })
                
            }
            
            
        }
        
    }
    
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
    
    func storePin(latitude: Double, longitude: Double) -> NSManagedObject {
        
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
                    
                    print(self.photos)
                    
//                    self.photosCollectionView.reloadData()
                    
                })
            })
            
            
        } catch let error as NSError  {
            
            print("Could not save \(error), \(error.userInfo)")
            
        }
        
        return pin
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
    
}




