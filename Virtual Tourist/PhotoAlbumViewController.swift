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
    @IBOutlet var reloadImageSetButton: UIBarButtonItem!
    var thisLocation:PinnedLocation!
    
    var imageContainers: [Image]!
    
    var sharedContext = CoreDataStack.sharedInstance().managedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoMapView.showAnnotations([thisLocation], animated: true)
        photoMapView.userInteractionEnabled = false
        collectionView.delegate = self
        collectionView.dataSource = self
        imageContainers = (thisLocation.imagesAtLocation.allObjects as! [Image]).sorted({ (first, second) -> Bool in
            first.fullURLString.hash < second.fullURLString.hash
        })
        // Do any additional setup after loading the view.
        reloadImageSetButton = UIBarButtonItem(title: "Get New Images", style: UIBarButtonItemStyle.Plain, target: self, action: "reloadImageSet")
        self.navigationController!.navigationBar.hidden = false
        //self.navigationController!.navigationItem.rightBarButtonItem = reloadImageSetButton
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadImageSetButton.enabled = true//thisLocation.allImagesHaveLoaded

        thisLocation.delegate = self
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
                self.collectionView.reloadItemsAtIndexPaths([NSIndexPath(forItem: n, inSection: 1)])
                break
            }
        }
        
        //check if all downloaded
        reloadImageSetButton.enabled = thisLocation.allImagesHaveLoaded
    }
    
    func removeImageAtIndexFromLocation(index:NSIndexPath){
        let image = imageContainers.removeAtIndex(index.item)
        self.collectionView.deleteItemsAtIndexPaths([index])
        thisLocation.removeImageFromLocation(image)
    }
    
    
}
