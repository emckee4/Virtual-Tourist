//
//  ExpandImageTransition.swift
//  Virtual Tourist
//
//  Created by Evan Mckee on 6/9/15.
//  Copyright (c) 2015 emckee. All rights reserved.
//

import UIKit

///This class provides a transition animation which expands the selected image in the album collection to its fullscreen size.
class ExpandImageTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    var originImageFrame:CGRect!
    //var destinationImageFrame:CGRect?
    var isPresenting = false
    let duration = 0.8
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView()
        let photoView = isPresenting ? transitionContext.viewForKey(UITransitionContextToViewKey)! : transitionContext.viewForKey(UITransitionContextFromViewKey)!
        
        let navController = (isPresenting ? transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!  : transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!) as! UINavigationController
        
        let albumVC = navController.topViewController as! PhotoAlbumViewController
        
        let initialFrame = isPresenting ? originImageFrame : photoView.frame
        let finalFrame = isPresenting ? photoView.frame : originImageFrame
        
        let xScaleFactor = isPresenting ?
            (initialFrame.width / finalFrame.width) :
            (finalFrame.width / initialFrame.width)
        
        let yScaleFactor = isPresenting ?
            (initialFrame.height / finalFrame.height) :
            (finalFrame.height / initialFrame.height)
        
        let scaleTransform = CGAffineTransformMakeScale(xScaleFactor, yScaleFactor)
        
        if isPresenting {
            
            photoView.transform = scaleTransform
            photoView.center = CGPoint( x: CGRectGetMidX(initialFrame), y: CGRectGetMidY(initialFrame))
            containerView.addSubview(photoView)
            
        } else {
        }

        containerView.bringSubviewToFront(photoView)
        
        UIView.animateWithDuration(duration, delay:0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: nil, animations: {
            
            photoView.transform = self.isPresenting ? CGAffineTransformIdentity : scaleTransform
            photoView.center = CGPoint(x: CGRectGetMidX(finalFrame), y: CGRectGetMidY(finalFrame))
            
            if self.isPresenting {
                albumVC.view.layer.zPosition += 1
                albumVC.view.alpha = 0.3
            } else {
                albumVC.view.layer.zPosition -= 1
                albumVC.view.alpha = 1.0
            }
            
            }, completion:{_ in
                transitionContext.completeTransition(true)
        })
        
    }
    

    
    
}
