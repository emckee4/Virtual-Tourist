
import MapKit

///mapView delegate functions
extension TravelMapViewController  {
    
    ///This is used to save displayed region in NSUserDefaults using the RegionPersister class as an intermediary.
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        RegionPersister.saveRegion(mapView.region)
    }
    
    ///Updates and saves PinnedLocation instance after a drag move
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        switch newState {
        case .Ending:
            let pinnedLocation = (view.annotation as! PinnedLocation)
            if pinnedLocation.hasChanges {
                CoreDataStack.sharedInstance().saveContext()
                println("saved new position")
            }
            return
        default:
            return
        }
    }
    
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "BasicAnnotationView")
        annotationView.draggable = true
        annotationView.animatesDrop = true
        return annotationView
    }
    

}
