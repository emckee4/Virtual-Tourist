//
//  Image.swift
//  Virtual Tourist
//
//  Created by Evan Mckee on 6/3/15.
//  Copyright (c) 2015 emckee. All rights reserved.
//

import UIKit
import CoreData

@objc(Image)
class Image: NSManagedObject {

    @NSManaged var fullURLString: String //filename of image as retrieved from flickr
    @NSManaged var title: String
    @NSManaged var locations: NSSet //we use the many to many relationship so that close pins won't download and store multiple copies of the same file

    private var downloadTask:NSURLSessionDownloadTask?
    
    private var fileName:String {
        return fullURLString.lastPathComponent
    }
    
    private var localPath:String {
        return Image.getImageDir().URLByAppendingPathComponent(fileName).path!
    }
    
    let imageDownloadCompleteNotification = "ImageDownloadCompleteNotification"
    
    
    ///Returns the associated stored image if it has been downloaded, nil otherwise
    var image:UIImage? {
        
        if let image = UIImage(contentsOfFile: localPath) {
            return image
        }
        return nil
    }
    
    var imageHasLoaded:Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(localPath)
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    ///should change this init such that it takes imageName only (or possible imagename + location). Init initiates download of data from the api manager
    
    init(imageURLString:String, title:String?, location:PinnedLocation , context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Image", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        self.fullURLString = imageURLString
        self.title = title ?? ""
        self.addLocation(location)
        self.downloadImage()
    }
    

    func addLocation(location:PinnedLocation){
        let mutableLocations:NSMutableSet = locations.mutableCopy() as! NSMutableSet
        mutableLocations.addObject(location)
        self.locations = NSSet(set: mutableLocations)
    }
    

    override func willSave() {
        //good place to check if not associated with any pins anymore -> delete()
        if self.locations.count == 0 && !self.deleted {
            self.managedObjectContext!.deleteObject(self)
        }
    }
    
    
    override func prepareForDeletion() {
        super.prepareForDeletion()
        self.downloadTask?.cancel()
        self.deleteStoredImage()
    }
    
    private func downloadImage(){
        let manager = NSFileManager.defaultManager()
        self.downloadTask = Flickr.sharedInstance().retrieveImageFromURL(self.fullURLString, completionHandler: { (fileLocationURL) -> Void in
            if (self as Image?) == nil {
                if let path = fileLocationURL {
                    manager.removeItemAtURL(path, error: nil)
                }
            } else if let path = fileLocationURL?.path {
                if manager.fileExistsAtPath(path) {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        //executing file move on main queue
                        var error:NSError?
                        manager.moveItemAtPath(path, toPath: self.localPath, error: &error)
                        self.notifyLocationsThatDownloadHasCompleted()

                    })
                }
            }
            
        })
        
    }
    
    private func deleteStoredImage(){
        let manager = NSFileManager.defaultManager()
        if manager.fileExistsAtPath(self.localPath){
            var error:NSError?
            manager.removeItemAtPath(self.localPath, error: &error)
        }
    }
    
    ///Checks if image is nil and download task has failed. If so this will restart the download task. This function is intended to be called by view controllers that wish to display an image that hasn't loaded for whatever reason.
    func retryDownloadIfNeeded(){
        if self.image == nil {
            if self.downloadTask?.state == NSURLSessionTaskState.Running {
                //task is in progress and presumably proceeding as it should. We return here without restarting. Once it times out we can restart.
                return
            }
            downloadImage()
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
                abort()
            }
        }
        return imageDir
    }
    
    func notifyLocationsThatDownloadHasCompleted(){
        for location in locations.allObjects as! [PinnedLocation]{
            location.imageAtLocationHasDownloaded(self)
        }
    }
    
    
}
