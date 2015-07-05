//
//  Post.swift
//  Makestagram
//
//  Created by Jevin Sidhu on 2015-07-02.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation
import Parse
import Bond

// To create a custom Parse class you need to inherit from PFObject and implement the PFSubclassing protocol
class Post : PFObject, PFSubclassing {
    
    func toggleLikePost(user: PFUser) {
        if (doesUserLikePost(user)) {
            // if image is liked, unlike it now
            // If the toggleLikePost method is called and a user likes a post, we unlike the post. First by removing the user from the local cache stored in the likes property, then by syncing the change with Parse. We remove the user from the local cache by using the filter method on the array stored in likes.value.
            likes.value = likes.value?.filter { $0 != user }
            ParseHelper.unlikePost(user, post: self)
        } else {
            // if this image is not liked yet, like it now
            // If the user doesn't like the post yet, we add them to the local cache and then synch the change with Parse.
            likes.value?.append(user)
            ParseHelper.likePost(user, post: self)
        }
    }
    
    
    //The contains function takes an array and an object and returns whether or not the object is stored inside of the array.
    func doesUserLikePost(user: PFUser) -> Bool {
        if let likes = likes.value {
            return contains(likes, user)
        } else {
            return false
        }
    }

    func fetchLikes() {
        
        // First we are checking whether likes.value already has stored a value or is nil. If we've already stored a value, we will skip the entire method. Waiting for cache refresh.
        if (likes.value != nil) {
            return
        }
        
        // We fetch the likes for the current Post using the method of ParseHelper that we created earlier
        ParseHelper.likesForPost(self, completionBlock: { (var likes: [AnyObject]?, error: NSError?) -> Void in
            
            // There is a new concept on this line: the filter method that we call on our Array. The filter method takes a closure and returns an array that only contains the objects from the original array that meet the requirement stated in that closure. The closure passed to the filter method gets called for each element in the array, each time passing the current element as the like argument to the closure. Note that you can pick any arbitrary name for the argument that we called like. So why are we filtering the array in the first place? We are removing all likes that belong to users that no longer exist in our Makestagram app (because their account has been deleted). Without this filtering the next statement could crash.

            likes = likes?.filter { like in like[ParseHelper.ParseLikeFromUser] != nil }
            
            // Here we are again using a new method: map. The map method behaves similar to the filter method in that it takes a closure that is called for each element in the array and in that it also returns a new array as a result. The difference is that, unlike filter, map does not remove objects but replaces them. In this particular case, we are replacing the likes in the array with the users that are associated with the like. We start with an array of likes and retrieve an array of users. Then we assign the result to our likes.value property.

            self.likes.value = likes?.map { like in
                let like = like as! PFObject
                let fromUser = like[ParseHelper.ParseLikeFromUser] as! PFUser
                
                return fromUser
            }
        })
    }
    
    // We make the property Dynamic so that we can listen to changes and update our UI after we've downloaded the likes for a post. We make it optional, because before we've downloaded the likes this property will be nil.
    
    var likes =  Dynamic<[PFUser]?>(nil)
    
    func downloadImage() {
        // Check if image.value already has a stored value. We do this to avoid that images are downloaded multiple times. Only if image.value is nil, want to start the download.

        if (image.value == nil) {
            
            // Here we start the download, instead of getData, getDataInBackgroundWithBlock - not blocking main thread.
            
            imageFile?.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
                if let data = data {
                    let image = UIImage(data: data, scale:1.0)!
                    
                    // Once  download completes, update the post.image. Accessing the .value property, image is a Dynamic.
                    self.image.value = image
                }
            }
        }
    }
    
    
    // Make image Dyanmic because of the use of bindings (->>) operator
    var image: Dynamic<UIImage?> = Dynamic(nil)
    var photoUploadTask: UIBackgroundTaskIdentifier?
    
    // Define each property that you want to access on this Parse class. Strings to Swift properties
    @NSManaged var imageFile: PFFile?
    @NSManaged var user: PFUser?
    
    //MARK: PFSubclassing Protocol
    
    func uploadPost() {
        // Whenever the uploadPost method is called, we grab the photo that shall be uploaded from the image property; turn it into a PFFile and upload it. Run in the bg.
        let imageData = UIImageJPEGRepresentation(image.value, 0.8)
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