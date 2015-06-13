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
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println("did deselect cell")
        let photoVC = FullSizePhotoViewController()
        photoVC.imageContainer = imageContainers[indexPath.item]
        let cellLayoutAttributes = collectionView.layoutAttributesForItemAtIndexPath(indexPath)
        self.transition.originImageFrame = collectionView.convertRect(cellLayoutAttributes!.frame, toView: self.view)
        photoVC.transitioningDelegate = self
        photoVC.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
        self.presentViewController(photoVC, animated: true, completion: nil)
        
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
