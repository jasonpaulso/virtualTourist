//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Jason Southwell on 2/13/17.
//  Copyright © 2017 Jason Southwell. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import MapKit
import CoreLocation
import SystemConfiguration

class MapViewController: UIViewController, MKMapViewDelegate {
    
    let flickrHandler = FlickrHandler()
    
    var pins: [Pin] = []
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        mapView.delegate = self
        super.viewDidLoad()
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(gestureRecognizer:)))
        gesture.minimumPressDuration = 1.5
        
        mapView.addGestureRecognizer(gesture)
        
        fetchPins()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        DispatchQueue.main.async {
            for item in self.mapView.selectedAnnotations {
                self.mapView.deselectAnnotation(item, animated: false)
            }
        }
        
    }
    
    func fetchPins() {
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        
        do {
            let results = try getContext().fetch(fetchRequest)
            
            if results.count > 0 {
                
                pins = results
                
                print(pins.count)
                
                for pin in pins {
                    let coord = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                    let annotation = PinAnnotation()
                    annotation.setCoordinate(newCoordinate: coord)
                    annotation.title = pin.name
                    annotation.objectID = pin.objectID
                    mapView.addAnnotation(annotation)
                }
                mapView.reloadInputViews()
            }
            
        } catch let error as NSError {
            
            print("Fetch error: \(error) description: \(error.userInfo)")
            
        }
        
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
                    let title = pm.locality ?? "Unknown Territory"
                    
                    print(pm)
                    
                    let pin = self.flickrHandler.storePin(latitude: latitude, longitude: longitude, name: title) as! Pin
                    
                  
                        
                    self.flickrHandler.taskForGETImagesByPin(completionHandlerForImageData: {result, _ in
                            
                        self.flickrHandler.getPinPhotos(completionHandlerForConvertData: {result,_ in
                           
//                            print("called in mvc")
                        })
                    })
            
                    
                    annotation.title = pin.name
                    
                    annotation.objectID = pin.objectID

                    self.mapView.addAnnotation(annotation)
                    
                } else {
                    annotation.title = "Unknown Place"
                    self.mapView.addAnnotation(annotation)
                    print("Problem with the data received from geocoder")
                }
                
            })
        }
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is PinAnnotation {
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
            
            pinAnnotationView.isDraggable = true
            pinAnnotationView.canShowCallout = true
            pinAnnotationView.animatesDrop = true
            
            pinAnnotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
            return pinAnnotationView
        }
        
        return nil
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if let annotation = view.annotation as? PinAnnotation {
            
//            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "collectionViewController") as! CollectionViewController
            
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "viewController") as! CollectionViewController
            
            if let retrievedPin = getContext().object(with: (annotation.objectID)!) as? Pin {
                
                viewController.currentPin = retrievedPin
                
                self.navigationController?.pushViewController(viewController, animated: true)
                
            }
            
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if let annotation = view.annotation as? PinAnnotation {
            
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "collectionViewController") as! CollectionViewController
            
            if let retrievedPin = getContext().object(with: (annotation.objectID)!) as? Pin {
                
                viewController.currentPin = retrievedPin
                
                self.navigationController?.pushViewController(viewController, animated: true)
                
            }
            
        }
    }
    
    
    
}



