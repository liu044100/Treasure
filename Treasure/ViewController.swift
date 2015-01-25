//
//  ViewController.swift
//  Treasure
//
//  Created by yuchen liu on 15/1/24.
//  Copyright (c) 2015年 rain. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    private var treasures: [Treasure] = []
    
    private var foundLocations: [GeoLocation] = []
    
    private var polyline: MKPolyline!

    @IBOutlet weak var mapView: MKMapView!
    
    private func markTreasureAsFound(treasure: Treasure){
        if let index = find(self.foundLocations, treasure.location){
            
            let alert = UIAlertController(title: "Oops!", message: "You've already found this treasure (at step \(index+1))! Try again!", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        }else{
            
            self.foundLocations.append(treasure.location)
            
            if self.polyline != nil{
                self.mapView.removeOverlay(self.polyline)
            }
            
            var coordinates = self.foundLocations.map{$0.coordinate}
            
            self.polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
            
            self.mapView.addOverlay(self.polyline)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.treasures = [
            HistoryTreasure(what: "Google's first office",
            year: 1999,
            latitude: 37.44451, longitude: -122.163369),
            
            HistoryTreasure(what: "Facebook's first office",
            year: 2005,
            latitude: 37.444268, longitude: -122.163271),
            
            FactTreasure(what: "Stanford University",
            fact: "Founded in 1885 by Leland Stanford.",
            latitude: 37.427474, longitude: -122.169719),
            
            FactTreasure(what: "Moscone West",
                fact: "Host to WWDC since 2003.",
                latitude: 37.783083, longitude: -122.404025),
            
            FactTreasure(what: "Computer History Museum",
                fact: "Home to a working Babbage Difference Engine.",
                latitude: 37.414371, longitude: -122.076817),
            
            HQTreasure(company: "Apple",
                latitude: 37.331741, longitude: -122.030333),
            
            HQTreasure(company: "Facebook",
                latitude: 37.485955, longitude: -122.148555),
            
            HQTreasure(company: "Google",
                latitude: 37.422, longitude: -122.084),
        ]
        
        self.mapView.delegate = self
        self.mapView.addAnnotations(self.treasures)
        
        let rectToDisplay = self.treasures.reduce(MKMapRectNull){
            (mapRect: MKMapRect, treasure: Treasure) -> (MKMapRect) in
            
            let treasurePointRect = MKMapRect(origin: treasure.location.mapPoint, size: MKMapSize(width: 0, height: 0))
            
            return MKMapRectUnion(mapRect, treasurePointRect)
        }
        
        self.mapView.setVisibleMapRect(rectToDisplay, edgePadding: UIEdgeInsetsMake(120, 10, 10, 20), animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
//        self.mapView.showAnnotations(self.treasures, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


extension ViewController: MKMapViewDelegate{
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        
            if let treasure = annotation as? Treasure{
                    var view = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as MKPinAnnotationView!
                    
                    
                    
                    if view == nil{
                        view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
                        view.canShowCallout = true
                        view.animatesDrop = false
                        view.pinColor = treasure.pinColor()
//                        view.calloutOffset = CGPoint(x: -5, y: 5);
                        view.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as UIView
                    }
                    
                    return view
    
            }else{
                return nil
            }
    }
    
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        if let treasure = view.annotation as? Treasure{
            if let alertable = treasure as? Alertable{
                
                let alert = alertable.alert()
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                
                alert.addAction(UIAlertAction(title: "Found", style: UIAlertActionStyle.Default, handler: { action in
                    self.markTreasureAsFound(treasure)
                    }))
                
                alert.addAction(UIAlertAction(title: "Find Nearest", style: UIAlertActionStyle.Default, handler: { action in
                    
                    var sortedTreasures = self.treasures
                    
                    sortedTreasures.sort{
                        
                        let distanceA = treasure.location.distanceBetween($0.location)
                        let distanceB = treasure.location.distanceBetween($1.location)
                        
                        
                        return distanceA < distanceB
                    }
                    
                    mapView.deselectAnnotation(treasure, animated: true)
                    mapView.selectAnnotation(sortedTreasures[1], animated: true)
                }))
                
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
        }
    }
    
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if let polylineOverlay = overlay as? MKPolyline{
            let renderer = MKPolylineRenderer(polyline: polylineOverlay)
            renderer.strokeColor = UIColor.blueColor()
            return renderer
        }
        
        return nil
    }
    
}

