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
    var currentPage: Int?
    var totalPagesAtLocation: Int?

    var coordinate: CLLocationCoordinate2D {
        get {return CLLocationCoordinate2DMake(self.latitude.doubleValue, self.longitude.doubleValue)}
        set {self.latitude = newValue.latitude; self.longitude = newValue.longitude}
    }
    
    var delegate:PinnedLocationDelegate?
    
    ///This holds the inprogress image array retrieval session so that it can be cancelled if the location is deleted or changed before it completes
    var flickrSession: NSURLSessionDataTask?
    
    var pointAnnotation:MKPointAnnotation {
        let coord = CLLocationCoordinate2DMake(self.latitude.doubleValue, self.longitude.doubleValue)
        let annotation = MKPointAnnotation()
        return annotation
    }
    
    var imageCount:Int {
        return imagesAtLocation.count
    }
    
    var allImagesHaveLoaded:Bool {
        for image in imagesAtLocation.allObjects as! [Image] {
            if image.imageHasLoaded == false {
                return false
            }
        }
        return true
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context) 
    }
    
    init(coordinate:CLLocationCoordinate2D, context:NSManagedObjectContext){
        let entity = NSEntityDescription.entityForName("PinnedLocation", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        self.coordinate = coordinate
        
        self.currentPage = -1
        self.totalPagesAtLocation = -1
    }
    
    override func prepareForDeletion() {
        super.prepareForDeletion()
        if flickrSession != nil {
            flickrSession!.cancel()
            flickrSession = nil
        }
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
        var nextPage:Int?
        if self.currentPage > 0 {
            if self.currentPage < self.totalPagesAtLocation {
                nextPage = self.currentPage! + 1
            }
        }
        println("getNewImages() with currentPage: \(self.currentPage), total: \(self.totalPagesAtLocation), nextPage: \(nextPage)")
        Flickr.sharedInstance().getImagesForCoordinates(latitude: self.latitude.doubleValue, longitude: self.longitude.doubleValue, page: nextPage) { (resultDict) -> Void in
            if let error = resultDict[Flickr.ResultKeys.error] as? NSError {
                println("error returned by resultdict")
                return
            }
            if let thisPage = resultDict[Flickr.ResultKeys.thisPage] as? Int, totalPages = resultDict[Flickr.ResultKeys.totalPages] as? Int{
                if thisPage > 0 && totalPages > 0{
                    self.currentPage = thisPage
                    self.totalPagesAtLocation = totalPages
                    println("Got new pages: currentPage: \(self.currentPage), totalPages: \(self.totalPagesAtLocation)")
                } else {
                    println("~~Didn't initialize page values")
                }
            }
            if let imageURLArray = resultDict[Flickr.ResultKeys.imageURLs] as? [String] {
                var newSet = Set(imageURLArray.map{ Image(imageURLString: $0, location: self, context: self.managedObjectContext!) })
                //MARK: Below will trigger deletion of all images which are no longer referenced
                self.imagesAtLocation = newSet
                self.delegate?.imageListHasBeenReloaded()   
            }
            if self.hasChanges {
                var error:NSError?
                self.managedObjectContext!.save(&error)
                if let error = error {
                    println("Error saving at conclusion of getNewImages completionHandler: \(error.localizedDescription)")
                }
            }
            
        }
    }
    
    func removeImageFromLocation(image:Image){
        self.imagesAtLocation = (self.imagesAtLocation as Set).subtract([image])
    }
    

    
    func imageAtLocationHasDownloaded(image:Image){
        //call this from individual images
        self.delegate?.imageHasDownloaded(image)
    }
    
}

protocol PinnedLocationDelegate {
    func imageHasDownloaded(image:Image)
    func imageListHasBeenReloaded()
}
