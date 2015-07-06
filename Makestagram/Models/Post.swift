//
//  File.swift
//  Makestagram
//Sidhu//  Created by Jevin Nguyen on 6/29/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//
import Foundation
import Parse
import Bond
import ConvenienceKit

// 1
class Post : PFObject, PFSubclassing {
    
    // 2
    @NSManaged var imageFile: PFFile?
    @NSManaged var user: PFUser?
    var image: Dynamic<UIImage?> = Dynamic(nil)
    var photoUploadTask: UIBackgroundTaskIdentifier?
    var likes =  Dynamic<[PFUser]?>(nil)
    static var imageCache: NSCacheSwift<String, UIImage>!
    
    
    //MARK: PFSubclassing Protocol
    
    // 3
    static func parseClassName() -> String {
        return "Post"
    }
    
    // 4
    override init () {
        super.init()
    }
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // inform Parse about this subclass
            self.registerSubclass()
            // We create an empty cache. Remember that the other lines in this method are primarily Parse boilerplate code.
            Post.imageCache = NSCacheSwift<String, UIImage>()
        }
    }
    func uploadPost() {
        let imageData = UIImageJPEGRepresentation(image.value, 0.8)
        let imageFile = PFFile(data: imageData)
        
        // 1
        photoUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
            UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
        }
        
        // 2
        imageFile.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            // 3
            UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
        }
        
        // any uploaded post should be associated with the current user
        user = PFUser.currentUser()
        self.imageFile = imageFile
        saveInBackgroundWithBlock(nil)
    }
    func downloadImage() {
        // We attempt to assign a value to image.value directly from the cache, using self.imageFile.name as key. If this assignment is successful the entire download block will be skipped.
        image.value = Post.imageCache[self.imageFile!.name]
        
        // if image is not downloaded yet, get it
        if (image.value == nil) {
            
            imageFile?.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
                if let data = data {
                    let image = UIImage(data: data, scale:1.0)!
                    self.image.value = image
                    // If we didn't have the image cached, we proceed as usual. Then, when the image is downloaded, we add it to the cache.
                    Post.imageCache[self.imageFile!.name] = image
                }
            }
        }
    }
    func fetchLikes() {
        // 1
        if (likes.value != nil) {
            return
        }
        
        // 2
        ParseHelper.likesForPost(self, completionBlock: { (var likes: [AnyObject]?, error: NSError?) -> Void in
            // 3
            likes = likes?.filter { like in like[ParseHelper.ParseLikeFromUser] != nil }
            
            // 4
            self.likes.value = likes?.map { like in
                let like = like as! PFObject
                let fromUser = like[ParseHelper.ParseLikeFromUser] as! PFUser
                
                return fromUser
            }
        })
    }
    func doesUserLikePost(user: PFUser) -> Bool {
        if let likes = likes.value {
            return contains(likes, user)
        } else {
            return false
        }
    }
    func toggleLikePost(user: PFUser) {
        if (doesUserLikePost(user)) {
            // if image is liked, unlike it now
            // 1
            likes.value = likes.value?.filter { $0 != user }
            ParseHelper.unlikePost(user, post: self)
        } else {
            // if this image is not liked yet, like it now
            // 2
            likes.value?.append(user)
            ParseHelper.likePost(user, post: self)
        }
    }
    
}