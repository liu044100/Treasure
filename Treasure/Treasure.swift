//
//  Treasure.swift
//  Treasure
//
//  Created by yuchen liu on 15/1/24.
//  Copyright (c) 2015年 rain. All rights reserved.
//

import Foundation
import MapKit

struct GeoLocation{
    var latitude: Double
    var longitude: Double
    
    func distanceBetween(other: GeoLocation) -> Double{
        
        let locationA = CLLocation(latitude: self.latitude, longitude: self.longitude)
        
        let locationB = CLLocation(latitude: other.latitude, longitude: other.longitude)
        
        return locationA.distanceFromLocation(locationB)

    }
}

extension GeoLocation{
    
    var coordinate: CLLocationCoordinate2D{
        return CLLocationCoordinate2DMake(self.latitude, self.longitude)
    }
    
    var mapPoint: MKMapPoint{
        return MKMapPointForCoordinate(self.coordinate)
    }
    
}

extension GeoLocation: Equatable{
}

func ==(lhs: GeoLocation, rhs: GeoLocation) -> Bool{
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}

class Treasure: NSObject{
    let what: String
    
    let location: GeoLocation
    
    init(what: String, location: GeoLocation){
        self.what = what
        self.location = location
    }
    
    convenience init(what: String, latitude: Double, longitude: Double){
        
        let location = GeoLocation(latitude: latitude, longitude: longitude)
        
        self.init(what: what, location: location)
    }
    
    func pinColor() -> MKPinAnnotationColor{
        return MKPinAnnotationColor.Red
    }
}

extension Treasure: MKAnnotation{
    
    var coordinate: CLLocationCoordinate2D {
        return self.location.coordinate
    }
    
    var title: String {
        return self.what
    }
    
}


@objc protocol Alertable{
    func alert() -> UIAlertController
}


// 1
final class HistoryTreasure: Treasure {
    let year: Int
    
    init(what: String, year: Int, latitude: Double, longitude: Double){
        
        let location = GeoLocation(latitude: latitude, longitude: longitude)
        
        self.year = year
        
        super.init(what: what, location: location)
    }
    
    override func pinColor() -> MKPinAnnotationColor {
        return MKPinAnnotationColor.Purple
    }
    
}

extension HistoryTreasure: Alertable{
    func alert() -> UIAlertController {
        let alter = UIAlertController(title: "History", message: "From \(self.year): \n\(self.what))", preferredStyle: UIAlertControllerStyle.Alert)
        
        return alter
    }
}

//2
final class FactTreasure: Treasure {
    let fact: String
    
    init(what: String, fact: String, latitude: Double, longitude: Double){
        
        let location = GeoLocation(latitude: latitude, longitude: longitude)
        
        self.fact = fact
        
        super.init(what: what, location: location)
    }
    
    override func pinColor() -> MKPinAnnotationColor {
        return MKPinAnnotationColor.Green
    }
}

extension FactTreasure: Alertable{
    func alert() -> UIAlertController {
        let alter = UIAlertController(title: "Fact", message: "\(self.what): \n\(self.fact))", preferredStyle: UIAlertControllerStyle.Alert)
        
        return alter
    }
}

//3
final class HQTreasure: Treasure {
    let company: String
    
    init(company: String, latitude: Double, longitude: Double){
        
        let location = GeoLocation(latitude: latitude, longitude: longitude)
        
        self.company = company
        
        super.init(what: company + " headquarters", location: location)
    }
    
}

extension HQTreasure: Alertable{
    func alert() -> UIAlertController {
        let alter = UIAlertController(title: "Headquarters", message: "The headquarters of \(self.company)", preferredStyle: UIAlertControllerStyle.Alert)
        
        return alter
    }
}