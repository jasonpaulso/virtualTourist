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


public let reloadNotification = "reload"

class FlickrHandler {
    
    var currentPin: Pin?
    
//    var photos = [Photo]()
    
    let managedContext = getContext()
    
    func storePhotosByPin(passedPhotos: [[String: AnyObject]], passedPin: Pin, completionHandlerForConvertData: (_ result: [Photo]?, _ error: String?) -> Void) {
        
        for passedPhoto in passedPhotos {
            
            let photo = Photo(context: managedContext)
            
            if let url = (passedPhoto["url_l"] as? String), let text = (passedPhoto["title"] as? String) {
                
                print(passedPhoto)
                
                photo.url = url
                
                photo.text = text
                
                photo.photo = NSData(contentsOf: URL(string: photo.url!)!)
                
                passedPin.addToPhotos(photo)
                
                
                do {
                    try managedContext.save()
                    
                    NotificationCenter.default.post(name: NSNotification.Name(reloadNotification), object: nil)
                    
                } catch let error as NSError {
                    
                    print("Save error: \(error), description: \(error.userInfo)")
                    
                    
                }
                
                completionHandlerForConvertData((currentPin?.photos?.array as! [Photo]), nil)
            }

            }
            
        
    }
    
    var page = 1
    
    func taskForGETImagesByPin(page: Int = 1, completionHandlerForImageData: @escaping (_ result: [Photo], _ error: String?) -> Void) {
        
        let queue = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])
        
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.BoundingBox: bboxString(latitude: (currentPin?.latitude)!, longitude: (currentPin?.longitude)!),
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.LargeURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback,
            Constants.FlickrParameterKeys.PerPage: "30",
            Constants.FlickrParameterKeys.Page: String(page)
        ]
        
        let url = flickrURLFromParameters(methodParameters as [String : AnyObject])
        
        Alamofire.request(url)
            .response(
                queue: queue,
                responseSerializer: DataRequest.jsonResponseSerializer(),
                completionHandler: { response in
                    // You are now running on the concurrent `queue` you created earlier.
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
                        print("CURRENT PAGE", page)
                        print("PAGES", photosDictionary[Constants.FlickrResponseKeys.Pages]!)
                        
                        /* GUARD: Is the "photo" key in photosDictionary? */
                        guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                            print("Cannot find key '\(Constants.FlickrResponseKeys.Photo)' in \(photosDictionary)")
                            return
                        }
 
                        
                        self.storePhotosByPin(passedPhotos: photosArray, passedPin: self.currentPin!, completionHandlerForConvertData: {result,_ in
                            
                            completionHandlerForImageData(result!, nil)
                            
                        })
                        
                    }
            })
        
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
        
        func storePin(latitude: Double, longitude: Double, name: String) -> NSManagedObject {
            
            let pin = Pin(context: getContext())
            
            let latitude = latitude
            
            let longitude = longitude
            
            let name = name
            
            pin.latitude = latitude
            
            pin.longitude = longitude
            
            pin.name = name
            
            do {
                try getContext().save()
                
                currentPin = pin
                
                
            } catch let error as NSError  {
                
                print("Could not save \(error), \(error.userInfo)")
                
            }
            
            return pin
        }
        
}



public func getContext() -> NSManagedObjectContext {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    return appDelegate.persistentContainer.viewContext
}





