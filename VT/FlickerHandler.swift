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

    let appDelegate = UIApplication.shared.delegate as? AppDelegate

    var page = 1

    func taskForGETPlaceID(latitude: Double, longitude: Double, completionHandler: @escaping (_ result: (String, String), _ error: String?) -> Void) {

        let lat = String(describing: latitude)

        let long = String(describing: longitude)

        let url = "https://api.flickr.com/services/rest/?method=flickr.places.findByLatLon&api_key=d242cd151d22b912ae2d878c19ec8209&lat=\(lat)&lon=\(long)&accuracy=10&format=json&nojsoncallback=1"

        Alamofire.request(url)
            .responseJSON(
                completionHandler: { response in

                    if let status = response.response?.statusCode {
                        switch status {
                        case 200: break
                        default:
                            print("error with response status: \(status)")
                        }
                    }

                    if let result = response.result.value {
                        
                        let JSON = result as? NSDictionary

                        guard let placesDictionary = JSON?["places"] as? [String:AnyObject] else {
                            let error = ("Cannot find key places in \(String(describing: JSON))")
                            completionHandler(("nil", "nil"), error)
                            return
                        }
                        guard let placeArray = placesDictionary["place"] as? [[String:AnyObject]] else {
                            let error = ("Cannot find key place in \(placesDictionary)")
                            completionHandler(("nil", "nil"), error)
                            return
                        }

                        guard let place = placeArray.first else {
                            let error = ("Cannot find key placeID in \(placeArray)")
                            completionHandler(("nil", "nil"), error)
                            return
                        }

                        let placeID = place["place_id"] as? String
                        let placeName = place["name"] as? String
                        let placeDetails = (placeID!, placeName!)

                        completionHandler(placeDetails, nil)
                    }

            })

    }

    func taskForGETImagesByPin(pin: Pin, page: Int = 1, completionHandlerForImageData: @escaping (_ result: Bool?, _ error: String?) -> Void) {

        let queue = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])

        let url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=d242cd151d22b912ae2d878c19ec8209&safe_search=1&place_id=\(pin.placeID!)&extras=url_m&per_page=30&page=\(String(page))&format=json&nojsoncallback=1&accuracy=16"

        Alamofire.request(url)
            .responseJSON(
                queue: queue,
                completionHandler: { response in
                    if let status = response.response?.statusCode {
                        switch status {
                        case 200: break
                        default:
                            print("error with response status: \(status)")
                        }
                    }

                    if let result = response.result.value {
                        let JSON = result as? NSDictionary

                        guard let photosDictionary = JSON?["photos"] as? [String:AnyObject] else {
                            let error = ("Cannot find key 'photos' in \(String(describing: JSON))")
                            completionHandlerForImageData(true, error)
                            return
                        }

                        let pages = photosDictionary["pages"]!.int16Value!

                        guard let photosArray = photosDictionary["photo"] as? [[String: AnyObject]] else {
                            let error = ("Cannot find key 'photo' in \(photosDictionary)")
                            completionHandlerForImageData(true, error)
                            return
                        }

                        PhotoPinModelHandler().storePhotosByPin(passedPhotos: photosArray, passedPin: pin, pages: pages)

                        completionHandlerForImageData(true, nil)

                    }
            })

    }

    func loadMorePhotos(currentPin: Pin, withCompletion completion: @escaping (_ result: Bool?, _ error: String?) -> Void) {

        page += 1

        if currentPin.photos != nil {

            currentPin.photos = nil
        }

        self.taskForGETImagesByPin(pin: currentPin, page: self.page, completionHandlerForImageData: {result, error in

            if error == nil {

                completion(true, nil)

            }

        })

    }

    func downloadImageData(photo: Photo) {

        
            DispatchQueue.main.async {
                Alamofire.request(photo.url!).responseData(completionHandler: { response in
                    
                    if let status = response.response?.statusCode {
                        switch status {
                        case 200: break
                        default:
                            print("error with response status: \(status)")
                        }
                    }
                    
                    if let data = response.result.value {
                        
                        let photoData = NSData(data: data)
                        
                        photo.photo = photoData
                        
                        self.appDelegate?.saveContext()
                        
                    }
                    
                })
            }

    }

}
