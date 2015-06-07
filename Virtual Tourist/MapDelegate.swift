
import MapKit

///mapView delegate functions
extension TravelMapViewController  {
    
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        RegionPersister.saveRegion(mapView.region)
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        

        switch newState {
        case .Ending:
            // (shared with didAddAnnotationViews) here we call prefetch of location info, array of associated picture names from flickr, creation of new image objects (and loading of that data by extension)
            let pinnedLocation = (view.annotation as! PinnedLocation)
            if pinnedLocation.hasChanges {
                CoreDataStack.sharedInstance().saveContext()
                println("saved new position")
            }
            
            //println("didChangeDragState from \(dragState(oldState)) to \(dragState(newState))")
            return
        case .Starting:
            // we should call cleanup on the old PinnedLocation data
            //println("didChangeDragState from \(dragState(oldState)) to \(dragState(newState))")
            return
        default:
            //println("ignore drag state change from \(dragState(oldState)) to \(dragState(newState))")
            return
        }
    }
    


    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "BasicAnnotationView")
        annotationView.draggable = true
        annotationView.animatesDrop = true
        return annotationView
    }
    
    
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        println("did select")
    }
    
    func mapView(mapView: MKMapView!, didDeselectAnnotationView view: MKAnnotationView!) {
        println("did deselect, state is \(dragState(view.dragState))")
    }
    
    
    func dragState(state:MKAnnotationViewDragState)->String{
        switch state {
        case .Canceling:
            return ".Canceling"
        case .Dragging:
            return ".Dragging"
        case .Ending:
            return ".Ending"
        case .None:
            return ".None"
        case .Starting:
            return ".Starting"
        }
    }
}
