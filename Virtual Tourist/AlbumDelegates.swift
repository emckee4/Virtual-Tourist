//
//  AlbumDelegates.swift
//  Virtual Tourist
//  Contains CollectionView and Transition delegates
//
//  Created by Evan Mckee on 6/9/15.
//  Copyright (c) 2015 emckee. All rights reserved.
//

import UIKit



extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource, UIViewControllerTransitioningDelegate {
    

    
    //MARK:- CollectionView datasource and delegate functions
    
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
    
    ///Cell selection begins the transition animation used to show the selected photo in scaled aspect fit.
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println("did deselect cell")
        let photoVC = FullSizePhotoViewController()
        photoVC.imageContainer = imageContainers[indexPath.item]
        let cellLayoutAttributes = collectionView.layoutAttributesForItemAtIndexPath(indexPath)
        self.transition.originImageFrame = collectionView.convertRect(cellLayoutAttributes!.frame, toView: self.view)
        photoVC.transitioningDelegate = self
        //The below setting ensures that the album view controller isn't removed from the view hierarchy. This means we can see it behind the selected image even after the transition has completed
        photoVC.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
        self.presentViewController(photoVC, animated: true, completion: nil)
        
    }
    
    //MARK:- PinnedLocationDelegate functions
    
    func imageHasDownloaded(image: Image) {
        // find image in array and reload it
        for (n,containedImage) in enumerate(imageContainers) {
            if containedImage === image {
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
    
    
//MARK:- Transitioning delegate functions
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = true
        println("album:acfpc")
        return transition
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = false
        return transition
    }

    
}
