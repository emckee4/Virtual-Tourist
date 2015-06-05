//
//  CoreDataStack.swift
//  Virtual Tourist
//
//  Created by Evan Mckee on 6/3/15.
//  Copyright (c) 2015 emckee. All rights reserved.
//

import UIKit
import CoreData

private let SQLITE_FILE_NAME = "VirtualTourist.sqlite"

class CoreDataStack: NSObject {
    
    class func sharedInstance()->CoreDataStack{
        struct Singleton {
            static var stack = CoreDataStack()
        }
        return Singleton.stack
    }
    
    lazy var managedObjectContext:NSManagedObjectContext! = {
        
        let moc = NSManagedObjectContext()
        moc.persistentStoreCoordinator = self.persistantStoreCoordinator
        return moc
    }()
    
    lazy var docDirectory:NSURL = {
        return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last as! NSURL
    }()
    
    lazy var persistantStoreCoordinator:NSPersistentStoreCoordinator = {
        
        let modelURL = NSBundle.mainBundle().URLForResource("Model", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOfURL: modelURL)
        let psc = NSPersistentStoreCoordinator(managedObjectModel: model!)
        let dbURL = self.docDirectory.URLByAppendingPathComponent(SQLITE_FILE_NAME)
        var error:NSError?
        if psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: dbURL, options: nil, error: &error) == nil {
            println("Error setting up PSC:")
            if let error = error {
                println(error.localizedDescription)
            } else {
                println("unknown error")
            }
            abort()
        }
        return psc
    }()
    
    ///Saves main context
    func saveContext(){
        var error:NSError?
        self.managedObjectContext.save(&error)
        if let error = error {
            println("ERROR SAVING CONTEXT:\n\(error.localizedDescription)")
        }
    }
    
    
    
}
