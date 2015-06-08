//
//  TravelMapViewController.swift
//  Virtual Tourist
//
//  Created by Evan Mckee on 6/2/15.
//  Copyright (c) 2015 emckee. All rights reserved.
//

import UIKit
import MapKit
import CoreData



class TravelMapViewController: UIViewController, MKMapViewDelegate{

    let mapRegionKey = "currentMapRegion"
    
    @IBOutlet var mapView:MKMapView!
    
    var tapRecogniser:UITapGestureRecognizer!
    
    var sharedContext = CoreDataStack.sharedInstance().managedObjectContext
    
    //No sorting is needed for this view
    let fetchRequest = NSFetchRequest(entityName: "PinnedLocation")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tapRecogniser = UITapGestureRecognizer(target: self, action: "handleTap:")
        self.mapView.delegate = self
        self.mapView.addGestureRecognizer(self.tapRecogniser)
        self.navigationItem.leftBarButtonItem = editButtonItem()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        //self.navigationController?.navigationBar.hidden = true
        if let region = RegionPersister.getSavedRegion() {
            self.mapView.setRegion(region, animated: true)
        }
        refreshAnnotations()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

 
    func handleTap(sender:UITapGestureRecognizer){
        println("screen tapped \(sender.state.rawValue)")
//        if (self.mapView.selectedAnnotations?.count ?? 0) > 0 {
//            println("annotations selected")
//        }

        let loc:CGPoint = sender.locationInView(sender.view!)
        if let hit = mapView.hitTest(loc, withEvent: nil){
            println("hit test found \(hit)")
            if hit is MKAnnotationView {
                println("Selection in progress: handleTap returning so as to avoid dropping a new pin")
                let pinnedLocation = (hit as! MKAnnotationView).annotation as! PinnedLocation
                pinSelected(pinnedLocation)
                return
            }
        }
        
        let coord = self.mapView.convertPoint(loc, toCoordinateFromView: self.mapView)
        
        let annotation = PinnedLocation(coordinate: coord, context: sharedContext)
        CoreDataStack.sharedInstance().saveContext()
        self.mapView.addAnnotation(annotation)
        
    }
    
    
    func refreshAnnotations(){
        var error:NSError?
        let results = self.sharedContext.executeFetchRequest(self.fetchRequest, error: &error)
        if let error = error {
            println("error refreshing annotations: \n\(error.localizedDescription)")
            return
        }
        if let annotations = results as? [PinnedLocation] {
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotations(annotations)
            println("updated \(annotations.count) annotations")
        }
       
    }
    
    func pinSelected(pin:PinnedLocation){
        if editing {
            mapView.removeAnnotation(pin)
            sharedContext.deleteObject(pin)
            CoreDataStack.sharedInstance().saveContext()
        } else {
        //pin.getNewImages()
        let photoVC = self.storyboard!.instantiateViewControllerWithIdentifier("PhotoAlbumScene") as! PhotoAlbumViewController
        photoVC.thisLocation = pin
        self.navigationController!.pushViewController(photoVC, animated: true)
        }
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        println("editing = \(editing.boolValue)")
    }
    
    

}



