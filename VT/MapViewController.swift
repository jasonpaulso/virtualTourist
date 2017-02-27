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

class MapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {

    let appDelegate = UIApplication.shared.delegate as? AppDelegate

    var context: NSManagedObjectContext?

    var pins = [Pin]()

    @IBOutlet var mapView: MKMapView!

    @IBAction func favoritesButtonClicked(_ sender: Any) {

        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "collectionViewController") as? PhotoAlbumViewController

        viewController?.predicate = NSPredicate(format: "isFavorite == %@", NSNumber(booleanLiteral: true))

        viewController?.passedTitle = "Favorites"

        navigationController?.pushViewController(viewController!, animated: true)

    }

    override func viewDidLoad() {

        super.viewDidLoad()

        context = appDelegate?.persistentContainer.viewContext

        mapView.delegate = self

        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(gestureRecognizer:)))

        gestureRecognizer.numberOfTouchesRequired = 1

        mapView.addGestureRecognizer(gestureRecognizer)

    }

    override func viewWillAppear(_ animated: Bool) {

        self.fetchPins()

//        DispatchQueue.main.async {
//            
//            if self.mapView.selectedAnnotations.count != 0 {
//                
//                for item in self.mapView.selectedAnnotations {
//
//                    self.mapView.deselectAnnotation(item, animated: false)
//                }
//            }
//            
//        }

    }

    override func viewDidDisappear(_ animated: Bool) {
        self.mapView.removeAnnotations(mapView.annotations)
    }

    let flickrHandler = FlickrHandler()
    let modelHandler = PhotoPinModelHandler()
    var annotation: MKPointAnnotation!

    func fetchPins() {

        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()

        do {
            let results = try context?.fetch(fetchRequest)

            if (results?.count)! > 0 {

                let pins = results

                for pin in pins! {

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

    @objc private func addAnnotation(gestureRecognizer: UIGestureRecognizer) {

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

                    self.modelHandler.storePin(latitude: latitude, longitude: longitude, completionHandler: {pin, _ in

                        annotation.title = pin.name

                        annotation.objectID = pin.objectID

                        self.mapView.addAnnotation(annotation)

                        self.flickrHandler.taskForGETImagesByPin(pin: pin, page: self.flickrHandler.page, completionHandlerForImageData: {_, _ in })

                    })

                } else {

                    annotation.title = "Unknown Place"

                    self.mapView.addAnnotation(annotation)

                    print("Problem with the data received from geocoder")

                }

            })
        }
    }

    internal func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Pin"

        if annotation is PinAnnotation {

            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {

                annotationView.annotation = annotation

                return annotationView

            } else {

                let annotationView = MKPinAnnotationView(annotation:annotation, reuseIdentifier: identifier)

                annotationView.isEnabled = true

                annotationView.canShowCallout = true

                annotationView.animatesDrop = true

                annotationView.pinTintColor = .blue

                let btn = UIButton(type: .detailDisclosure)

                annotationView.rightCalloutAccessoryView = btn

                return annotationView
            }
        }

        return nil
    }

    internal func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        if let annotation = view.annotation as? PinAnnotation {

            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "collectionViewController") as? PhotoAlbumViewController

            if let retrievedPin = context?.object(with: (annotation.objectID)!) as? Pin {

                viewController?.currentPin = retrievedPin

                self.navigationController?.pushViewController(viewController!, animated: true)

            }

        }
    }

    internal func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

        if let annotation = view.annotation as? PinAnnotation {

            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "collectionViewController") as? PhotoAlbumViewController

            if let retrievedPin = context?.object(with: (annotation.objectID)!) as? Pin {

                viewController?.currentPin = retrievedPin

                self.navigationController?.pushViewController(viewController!, animated: true)

            }

        }
    }

}
