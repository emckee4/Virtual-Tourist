//
//  RegionContainer.swift
//  Virtual Tourist
//
//  Created by Evan Mckee on 6/3/15.
//  Copyright (c) 2015 emckee. All rights reserved.
//

import Foundation
import MapKit


/// NSCoding compliant container for MKCoordinateRegion structs
class RegionPersister:NSObject, NSCoding {
    
    var coordLat:Double
    var coordLon:Double
    var spanLat:Double
    var spanLon:CLLocationDegrees
    
    
    struct Keys {
        static let coordinateLatitude = "CoordinateLatitude"
        static let coordinateLongitude = "CoordinateLongitude"
        static let spanLatitude = "SpanLatitude"
        static let spanLongitude = "SpanLongitude"
        
        static let storedRegion = "StoredRegion"
    }
    
    init(region:MKCoordinateRegion) {
        self.coordLat = region.center.latitude
        self.coordLon = region.center.longitude
        self.spanLat = region.span.latitudeDelta
        self.spanLon = region.span.longitudeDelta
    }
    
    
    required init(coder aDecoder: NSCoder) {
        self.coordLat = aDecoder.decodeDoubleForKey(Keys.coordinateLatitude)
        self.coordLon = aDecoder.decodeDoubleForKey(Keys.coordinateLongitude)
        self.spanLat = aDecoder.decodeDoubleForKey(Keys.spanLatitude)
        self.spanLon = aDecoder.decodeDoubleForKey(Keys.spanLongitude)
        
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeDouble(coordLat, forKey: Keys.coordinateLatitude)
        aCoder.encodeDouble(coordLon, forKey: Keys.coordinateLongitude)
        aCoder.encodeDouble(spanLat, forKey: Keys.spanLatitude)
        aCoder.encodeDouble(spanLon, forKey: Keys.spanLongitude)
    }
    
    class func saveRegion(region:MKCoordinateRegion){
        let container = RegionPersister(region: region)
        NSUserDefaults.standardUserDefaults().setObject(NSKeyedArchiver.archivedDataWithRootObject(container), forKey: Keys.storedRegion)
    }
    
    class func getSavedRegion()->MKCoordinateRegion?{
        if let data = NSUserDefaults.standardUserDefaults().objectForKey(Keys.storedRegion) as? NSData {
            let container = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! RegionPersister
            let center = CLLocationCoordinate2D(latitude: container.coordLat, longitude: container.coordLon)
            let span = MKCoordinateSpan(latitudeDelta: container.spanLat, longitudeDelta: container.spanLon)
            println("getSavedRegion returning a region")
            return MKCoordinateRegion(center: center, span: span)
        }
        println("getSavedRegion returning nil")
        return nil
    }
    
}