//
//  Post.swift
//  Makestagram
//
//  Created by Jevin Sidhu on 2015-07-02.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation
import Parse

// To create a custom Parse class you need to inherit from PFObject and implement the PFSubclassing protocol
class Post : PFObject, PFSubclassing {
    
    var image: UIImage?
    var photoUploadTask: UIBackgroundTaskIdentifier?
    
    // Define each property that you want to access on this Parse class. Strings to Swift properties
    @NSManaged var imageFile: PFFile?
    @NSManaged var user: PFUser?
    
    //MARK: PFSubclassing Protocol
    
    func uploadPost() {
        // Whenever the uploadPost method is called, we grab the photo that shall be uploaded from the image property; turn it into a PFFile and upload it. Run in the bg.
        let imageData = UIImageJPEGRepresentation(image, 0.8)
        let imageFile = PFFile(data: imageData)
        
        
        // Create bg task and also end temp resoucres
        photoUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
            UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
        }
        
        // Save in the bg
        imageFile.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            // The API for background jobs makes us responsible for calling UIApplication.sharedApplication().endBackgroundTask as soon as our work is completed.
            UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
        }
        // any uploaded post should be associated with the current user
        user = PFUser.currentUser()
        
        // Once we have saved the imageFile we assign it to self (which is the Post that's being uploaded). Then we call save() to store the Post. Run in the bg.
        self.imageFile = imageFile
        saveInBackgroundWithBlock(nil)
    }
    
    // By implementing the parseClassName you create a connection between the Parse class and your Swift class.
    static func parseClassName() -> String {
        return "Post"
    }
    
    // Pure boilerplate
    override init () {
        super.init()
    }
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // inform Parse about this subclass
            self.registerSubclass()
        }
    }
    
}