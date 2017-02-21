//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Jason Southwell on 2/13/17.
//  Copyright © 2017 Jason Southwell. All rights reserved.
//

import UIKit
import Alamofire
//import AlamofireCoreData
import CoreData
////import AlamofireObjectMapper
//import ObjectMapper
import MapKit
import CoreLocation
import SystemConfiguration

class MapViewController: UIViewController, MKMapViewDelegate {
    
    
//    func storePin (latitude: Double, longitude: Double, name: String) -> NSManagedObjectID {
//        
//        let context = getContext()
//        
//        let entity =  NSEntityDescription.entity(forEntityName: "Pin", in: context)
//        
//        let pin = NSManagedObject(entity: entity!, insertInto: context)
//        
//        pin.setValue(latitude, forKey: "latitude")
//        pin.setValue(longitude, forKey: "longitude")
//        pin.setValue(name, forKey: "name")
//        
//        do {
//            try context.save()
//            print("pin saved!")
//        } catch let error as NSError  {
//            print("Could not save \(error), \(error.userInfo)")
//        } catch {
//            
//        }
//        
//     return pin.objectID
//        
//    }

    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        mapView.delegate = self
        super.viewDidLoad()
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(gestureRecognizer:)))
        gesture.minimumPressDuration = 1.5

        mapView.addGestureRecognizer(gesture)
    }
    
    func addAnnotation(gestureRecognizer:UIGestureRecognizer){
        
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let annotation = PinAnnotation()
            annotation.setCoordinate(newCoordinate: newCoordinates)
            
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude), completionHandler: {(placemarks, error) -> Void in
                if error != nil {
                    print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                    return
                }
                
                if (placemarks?.count)! > 0 {
                    
                    let pm = (placemarks?[0])! as CLPlacemark
                    
                    let latitude = pm.location!.coordinate.latitude
                    let longitude = pm.location!.coordinate.longitude
                    let title = pm.locality
                    let controller = CollectionViewController()
                    let pin = controller.storePin(latitude: latitude, longitude: longitude)
                    
                    annotation.title = title
        
                    annotation.objectID = pin.objectID
                    
                    self.mapView.addAnnotation(annotation)
                    print(pm)
                } else {
                    annotation.title = "Unknown Place"
                    self.mapView.addAnnotation(annotation)
                    print("Problem with the data received from geocoder")
                }

            })
        }
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        if let annotation = view.annotation as? PinAnnotation {
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "collectionViewController") as! CollectionViewController
            if let retrievedPin = getContext().object(with: (annotation.objectID)!) as? Pin {
                viewController.currentPin = retrievedPin
                self.navigationController?.pushViewController(viewController, animated: true)

            }

        }
    }


}

