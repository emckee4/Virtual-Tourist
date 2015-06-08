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

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate, PinnedLocationDelegate {

    @IBOutlet var photoMapView:MKMapView!
    @IBOutlet var collectionView:UICollectionView!
    var reloadImageSetButton: UIBarButtonItem!
    var thisLocation:PinnedLocation!
    
    var imageContainers: [Image]!
    
    var sharedContext = CoreDataStack.sharedInstance().managedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //photoMapView.showAnnotations([thisLocation], animated: false)
        //photoMapView.camera.altitude = 100000
        setMapCenter()
        photoMapView.userInteractionEnabled = false
        collectionView.delegate = self
        collectionView.dataSource = self
        reloadImageContainerArray()
        // Do any additional setup after loading the view.
        reloadImageSetButton = UIBarButtonItem(title: "Get New Images", style: UIBarButtonItemStyle.Plain, target: self, action: "reloadImageSet")
        self.navigationController!.navigationBar.hidden = false
        self.navigationItem.rightBarButtonItem = reloadImageSetButton
        self.automaticallyAdjustsScrollViewInsets = false
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadImageSetButton.enabled = true//thisLocation.allImagesHaveLoaded
        thisLocation.delegate = self
        if Flickr.sharedInstance().connectionIsOffline() {
            self.showOfflineAlert()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let thisImageContainer = imageContainers[indexPath.item]
        if let image:UIImage = thisImageContainer.image {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionViewCell", forIndexPath: indexPath) as! PhotoCell
            cell.imageView.image = image
            return cell
        } else {
            return collectionView.dequeueReusableCellWithReuseIdentifier("placeholderCell", forIndexPath: indexPath) as! PlaceholderCell
            
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageContainers.count
    }
    
    func reloadImageSet(){
        thisLocation.getNewImages()
        reloadImageSetButton.enabled = true
    }
    
    
    func imageHasDownloaded(image: Image) {
        // find image in array and reload it
        for (n,containedImage) in enumerate(imageContainers) {
            if containedImage === image {
                //reload cell
                self.collectionView.reloadItemsAtIndexPaths([NSIndexPath(forItem: n, inSection: 0)])
                break
            }
        }
        
        //check if all downloaded
        reloadImageSetButton.enabled = thisLocation.allImagesHaveLoaded
    }
    func imageListHasBeenReloaded() {
        reloadImageContainerArray()
        self.collectionView.reloadData()
    }
    
    func removeImageAtIndexFromLocation(index:NSIndexPath){
        let image = imageContainers.removeAtIndex(index.item)
        self.collectionView.deleteItemsAtIndexPaths([index])
        thisLocation.removeImageFromLocation(image)
    }
    
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
    
    func setMapCenter(){
        let center = thisLocation.coordinate
        photoMapView.addAnnotation(thisLocation)
        //let mapWidth = self.photoMapView.bounds.width
        //let mapHeight = self.photoMapView
        //let span = MKCoordinateSpan(latitudeDelta: <#CLLocationDegrees#>, longitudeDelta: <#CLLocationDegrees#>)
        let camera = MKMapCamera(lookingAtCenterCoordinate: center, fromEyeCoordinate: center, eyeAltitude: 500000.0)
        photoMapView.setCamera(camera, animated: true)
    }
}
