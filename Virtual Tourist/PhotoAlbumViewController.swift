//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Evan Mckee on 6/3/15.
//  Copyright (c) 2015 emckee. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, PinnedLocationDelegate {

    @IBOutlet var photoMapView:MKMapView!
    @IBOutlet var collectionView:UICollectionView!
    
    var reloadImageSetButton: UIBarButtonItem!
    var thisLocation:PinnedLocation!
    let transition = ExpandImageTransition()
    var longPressRecognizer:UILongPressGestureRecognizer!
    var imageContainers: [Image]!
    var sharedContext = CoreDataStack.sharedInstance().managedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMapCenter()
        photoMapView.userInteractionEnabled = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.blackColor()
        reloadImageContainerArray()
        // Do any additional setup after loading the view.
        reloadImageSetButton = UIBarButtonItem(title: "Get New Images", style: UIBarButtonItemStyle.Plain, target: self, action: "reloadImageSet")
        self.navigationController!.navigationBar.hidden = false
        self.navigationItem.rightBarButtonItem = reloadImageSetButton
        self.automaticallyAdjustsScrollViewInsets = false
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressHandler:")
        collectionView.addGestureRecognizer(longPressRecognizer)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadImageSetButton.enabled = true
        thisLocation.delegate = self
        if Flickr.sharedInstance().connectionIsOffline() {
            self.showOfflineAlert()
        }
        for container in imageContainers {
            //restarts downloads of any images which are nil and which don't have active download sessions
            container.retryDownloadIfNeeded()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func reloadImageSet(){
        thisLocation.getNewImages()
        reloadImageSetButton.enabled = true
    }
    
    ///Disassociates the selected image from the currently displayed PinnedLocation and saves the context. If that was the only location associated with the image (which should be the case in almost all situations) then the Image instance will delete itself on save.
    func removeImageAtIndexFromLocation(index:NSIndexPath){
        let image = imageContainers.removeAtIndex(index.item)
        self.collectionView.deleteItemsAtIndexPaths([index])
        thisLocation.removeImageFromLocation(image)
        CoreDataStack.sharedInstance().saveContext()
    }
    
    ///Shows an alert if the most recent server requests failed prior to the load of this view.
    func showOfflineAlert(){
        let alert = UIAlertController(title: "Connection Offline", message: "Your internet connection appears to be offline", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            reloadImageSetButton
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: {(action) -> Void in
        }))
        self.presentViewController(alert, animated: true, completion: nil)  
    }
    
    func reloadImageContainerArray(){
        imageContainers = (thisLocation.imagesAtLocation.allObjects as! [Image]).sorted({ (first, second) -> Bool in
            first.fullURLString.hash < second.fullURLString.hash
        })
    }
    
    ///This function orients the top mapView to the selected pin
    private func setMapCenter(){
        let center = thisLocation.coordinate
        photoMapView.addAnnotation(thisLocation)
        let camera = MKMapCamera(lookingAtCenterCoordinate: center, fromEyeCoordinate: center, eyeAltitude: 500000.0)
        photoMapView.setCamera(camera, animated: true)
    }
    
    ///The longPress handler enables the deletion of images in the album. 
    func longPressHandler(sender:UILongPressGestureRecognizer){
        if sender.state != UIGestureRecognizerState.Began {
            return
        }
        let loc:CGPoint = sender.locationInView(sender.view!)
        if let indexPath = collectionView.indexPathForItemAtPoint(loc) {
            removeImageAtIndexFromLocation(indexPath)
        }
    }
    
}
