//
//  ExpandImageTransition.swift
//  Virtual Tourist
//
//  Created by Evan Mckee on 6/9/15.
//  Copyright (c) 2015 emckee. All rights reserved.
//

import UIKit


class ExpandImageTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    var originImageFrame:CGRect!
    var destinationImageFrame:CGRect?
    var isPresenting = false
    let duration = 0.8
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        println("ET:at")
        
        let containerView = transitionContext.containerView()
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        let photoView = isPresenting ? toView : transitionContext.viewForKey(UITransitionContextFromViewKey)!
        
        let initialFrame = isPresenting ? originImageFrame : photoView.frame
        let finalFrame = isPresenting ? photoView.frame : originImageFrame
        
        let xScaleFactor = isPresenting ?
            initialFrame.width / finalFrame.width :
            finalFrame.width / initialFrame.width
        
        let yScaleFactor = isPresenting ?
            initialFrame.height / finalFrame.height :
            finalFrame.height / initialFrame.height
        
        let scaleTransform = CGAffineTransformMakeScale(xScaleFactor, yScaleFactor)
        
        if isPresenting {
            photoView.transform = scaleTransform
            photoView.center = CGPoint( x: CGRectGetMidX(initialFrame), y: CGRectGetMidY(initialFrame))
            //photoView.clipsToBounds = true
        }
        
        containerView.addSubview(toView)
        containerView.bringSubviewToFront(photoView)
        
        UIView.animateWithDuration(duration, delay:0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: nil, animations: {
            
            photoView.transform = self.isPresenting ? CGAffineTransformIdentity : scaleTransform
            photoView.center = CGPoint(x: CGRectGetMidX(finalFrame), y: CGRectGetMidY(finalFrame))
            
            }, completion:{_ in
                transitionContext.completeTransition(true)
        })
        
    }
    

    
    
}
