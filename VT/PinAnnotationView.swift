//
//  AnnotationView.swift
//  Virtual Tourist
//
//  Created by Jason Southwell on 2/14/17.
//  Copyright © 2017 Jason Southwell. All rights reserved.
//

import MapKit
import Foundation
import UIKit
import CoreData

class PinAnnotation : MKAnnotationView, MKAnnotation {
    private var coord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return coord
        }
    }
    
    var title: String?
    var subtitle: String?
    var objectID: NSManagedObjectID?
    
    
    
    
    func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
        self.coord = newCoordinate

    }
}
