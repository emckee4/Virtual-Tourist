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
    var longPressRecognizer:UILongPressGestureRecognizer!
    
    var sharedContext = CoreDataStack.sharedInstance().managedObjectContext
    
    //No sorting is needed for this view
    let fetchRequest = NSFetchRequest(entityName: "PinnedLocation")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tapRecogniser = UITapGestureRecognizer(target: self, action: "handleTap:")
        self.longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        //longPressRecognizer.minimumPressDuration = 0.48
        self.mapView.delegate = self
        self.mapView.addGestureRecognizer(self.tapRecogniser)
        self.mapView.addGestureRecognizer(longPressRecognizer)
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

    ///Handler for tap gesture recognizer. This seems to work a little more reliably in selecting pins under the proper circumstances than do the mapView delegate functions, at least when we're also including dragging and long press functionality. This function looks at the tap location and if a pin is found there it calls pinSelected to trigger the transition to the photoAlbum view
    func handleTap(sender:UITapGestureRecognizer){
        println("screen tapped \(sender.state.rawValue)")
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
    }
    ///Long press gesture recognizer handler. This is used to drop a new pin (creating a new PinnedLocation instance in the process) if the target location is unoccupied by another pin. In practice though the hit check is probably unnecessary since the drag recognizer in the mapView seems to take precedence in pinned regions.
    func handleLongPress(sender:UILongPressGestureRecognizer){
        println("LongPress")
        let loc:CGPoint = sender.locationInView(sender.view!)
        if let hit = mapView.hitTest(loc, withEvent: nil){
            println("hit test found \(hit)")
            if hit is MKAnnotationView {
                println("Selection in progress: handleTap returning so as to avoid dropping a new pin")
                //let pinnedLocation = (hit as! MKAnnotationView).annotation as! PinnedLocation
                //let annoView = mapView(self.mapView, viewForAnnotation: pinnedLocation)
                return
            }
        }
        let coord = self.mapView.convertPoint(loc, toCoordinateFromView: self.mapView)
        let annotation = PinnedLocation(coordinate: coord, context: sharedContext)
        CoreDataStack.sharedInstance().saveContext()
        self.mapView.addAnnotation(annotation)
    }
    
    ///Retrieves and reloads all pin locations
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
    
    ///Normally this triggers a transition to the album view associated with the selected pin. If in editing mode this deletes the pinnedLocation instance.
    func pinSelected(pin:PinnedLocation){
        if editing {
            mapView.removeAnnotation(pin)
            sharedContext.deleteObject(pin)
            CoreDataStack.sharedInstance().saveContext()
        } else {
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



