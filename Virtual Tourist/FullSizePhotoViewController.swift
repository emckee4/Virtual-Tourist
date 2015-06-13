//
//  FullSizePhotoViewController.swift
//  Virtual Tourist
//
//  Created by Evan Mckee on 6/9/15.
//  Copyright (c) 2015 emckee. All rights reserved.
//

import UIKit

class FullSizePhotoViewController: UIViewController, UIViewControllerTransitioningDelegate {

    
    var imageContainer:Image!
    
    var imageView:UIImageView!
    
    var gestureRecognizer:UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.imageView = UIImageView(image:imageContainer.image)
        //set to aspect fill based on size of frame (possibly do this in view will appear)
        
        imageView.contentMode = UIViewContentMode.Center
        let screenBounds = UIScreen.mainScreen().coordinateSpace.bounds
        println("screenBounds: \(screenBounds)")

        if !CGRectContainsRect(screenBounds, imageView.frame){
            imageView.contentMode = UIViewContentMode.ScaleAspectFit
            println("scale aspect fit")
        }
        imageView.frame = screenBounds
        self.view.addSubview(self.imageView)
        self.view.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        self.gestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissTap")
        self.view.addGestureRecognizer(gestureRecognizer)
        println("FSPVC:vdl")
        self.imageView.backgroundColor = UIColor.clearColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    
    func dismissTap(){
        println("FSPVC:dT")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

}
