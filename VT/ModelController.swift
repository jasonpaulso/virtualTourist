//
//  ModelController.swift
//  VirtualTourist
//
//  Created by Jason Southwell on 2/24/17.
//  Copyright © 2017 Jason Southwell. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PhotoPinModelHandler {

    weak var appDelegate = UIApplication.shared.delegate as? AppDelegate

    func deleteSelectedImage(photo: Photo) {

        if !(photo.isFavorite) {

            appDelegate?.persistentContainer.viewContext.delete(photo)

            appDelegate?.saveContext()

        }

    }

    func addToFavorites(passedPhoto: Photo) {

        passedPhoto.isFavorite = true

        appDelegate?.saveContext()

    }

    func storePin(latitude: Double, longitude: Double, completionHandler: @escaping (_ result: Pin, _ error: String?) -> Void) {

        let currentPin = Pin(context: (appDelegate?.persistentContainer.viewContext)!)

        let latitude = latitude

        let longitude = longitude

        FlickrHandler().taskForGETPlaceID(latitude: latitude, longitude: longitude, completionHandler: {result, _ in

            currentPin.latitude = latitude
            currentPin.longitude = longitude
            currentPin.name = result.1
            currentPin.placeID = result.0
            self.appDelegate?.saveContext()

            completionHandler(currentPin, nil)
        })

    }

    func storePhotosByPin(passedPhotos: [[String: AnyObject]], passedPin: Pin, pages: Int16) {

        for passedPhoto in passedPhotos {

            DispatchQueue.main.async {

                let photo = Photo(context: (self.appDelegate?.persistentContainer.viewContext)!)

                if let url = (passedPhoto["url_m"] as? String), let text = (passedPhoto["title"] as? String) {

                    photo.url = url

                    photo.text = text

                    FlickrHandler().downloadImageData(photo: photo)

                    passedPin.addToPhotos(photo)

                    self.appDelegate?.saveContext()

                }

            }

        }

    }

}
