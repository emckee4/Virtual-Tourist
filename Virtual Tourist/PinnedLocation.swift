//
//  PinnedLocation.swift
//  Virtual Tourist
//
//  Created by Evan Mckee on 6/3/15.
//  Copyright (c) 2015 emckee. All rights reserved.
//

import MapKit
import CoreData

@objc(PinnedLocation)
class PinnedLocation: NSManagedObject, MKAnnotation {

    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var imagesAtLocation: NSSet
    
    ///These values are maintained to help ensure we get 
    @NSManaged private var currentPage: NSNumber
    @NSManaged private var totalPagesAtLocation: NSNumber

    var coordinate: CLLocationCoordinate2D {
        get {return CLLocationCoordinate2DMake(self.latitude.doubleValue, self.longitude.doubleValue)}
        set {self.latitude = newValue.latitude; self.longitude = newValue.longitude}
    }
    
    
    ///This holds the inprogress image array retrieval session so that it can be cancelled if the location is deleted before this completes
    var flickrSession: NSURLSessionDataTask?
    
    var pointAnnotation:MKPointAnnotation {
        let coord = CLLocationCoordinate2DMake(self.latitude.doubleValue, self.longitude.doubleValue)
        let annotation = MKPointAnnotation()
        return annotation
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context) 
    }
    
    init(coordinate:CLLocationCoordinate2D, context:NSManagedObjectContext){
        let entity = NSEntityDescription.entityForName("PinnedLocation", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        self.coordinate = coordinate
    }
    
    
    override func willSave() {
        //check which values changed, if lat or lon changed then empty images and call getNewImages
        if self.changedValues()["latitude"] != nil || self.changedValues()["longitude"] != nil {
            println("PInnedLocation:willSave() location changed, refreshing data")
            getNewImages()
        }
    }
    
    
    
    func getNewImages(){
        if flickrSession != nil {
            flickrSession!.cancel()
            println("flickrSession for location cancelled by getNewImages()")
        }
        
        Flickr.sharedInstance()
    }
    
    
}
