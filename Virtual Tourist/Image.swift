//
//  Image.swift
//  Virtual Tourist
//
//  Created by Evan Mckee on 6/3/15.
//  Copyright (c) 2015 emckee. All rights reserved.
//

import Foundation
import CoreData

@objc(Image)
class Image: NSManagedObject {

    @NSManaged var imageName: String //filename of image as retrieved from flickr
    @NSManaged var locations: NSSet //we use the many to many relationship so that close pins won't download and store multiple copies of the same file

    //add fetchDate so that images can be saved until we know whether we
    
   // var image:UIImage {
        //should return placeholder if image == nil
        
   //     return
   // }
    
    
    ///should change this init such that it takes imageName only (or possible imagename + location). Init initiates download of data from the api manager
    
    init(imageName:String, imageData:NSData, location:PinnedLocation , context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Image", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        let imageDir = Image.getImageDir()
        let imageURL = imageDir.URLByAppendingPathComponent(imageName)
        if NSFileManager.defaultManager().fileExistsAtPath(imageURL.path!) {
            //image already exists in the store.
            println("Image.init(): FILE ALREADY EXISTS- THIS SHOULD NOT HAPPEN")
        }
        imageData.writeToFile(imageURL.path!, atomically: true)
        self.imageName = imageName
        self.addLocation(location)
    }
    

    func addLocation(location:PinnedLocation){
        let mutableLocations:NSMutableSet = locations.mutableCopy() as! NSMutableSet
        mutableLocations.addObject(location)
        self.locations = NSSet(set: mutableLocations)
    }
    

    override func willSave() {
        //good place to check if not associated with any pins anymore -> delete()
        if self.locations.count == 0 {
            self.managedObjectContext!.deleteObject(self)
        }
    }
    

    
    ///gets image directory if it exists, sets it up and returns it if not
    class func getImageDir()->NSURL{
        let docDir = CoreDataStack.sharedInstance().docDirectory
        let imageDir = docDir.URLByAppendingPathComponent("images", isDirectory: true)
        if !NSFileManager.defaultManager().fileExistsAtPath(imageDir.path!) {
            var error:NSError?
            NSFileManager.defaultManager().createDirectoryAtURL(imageDir, withIntermediateDirectories: false, attributes: nil, error: &error)
            if let error = error {
                println("error creating image dir \(error.localizedDescription)")
                abort()
            }
        }
        return imageDir
    }
}
