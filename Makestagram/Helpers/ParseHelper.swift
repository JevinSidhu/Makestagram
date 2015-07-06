//
//  ParseHelper.swift
//  Makestagram
//
//  Created by Jevin Sidhu on 2015-07-04.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation
import Parse

// We are going to wrap all of our helper methods into a class called ParseHelper. We only do this so that all of the functions are bundled under the ParseHelper namespace. That makes the code easier to read in some cases. To call the timeline request function you call ParseHelper.timelineRequestforUser... instead of simply timelineRequestforUser. That way you always know exactly in which file you can find the methods that are being called.

class ParseHelper {
    
    
// MARK: Likes
    static func likePost(user: PFUser, post: Post) {
        let likeObject = PFObject(className: ParseLikeClass)
        likeObject[ParseLikeFromUser] = user
        likeObject[ParseLikeToPost] = post
        
        likeObject.saveInBackgroundWithBlock(nil)
    }
    
    static func unlikePost(user: PFUser, post: Post) {
        // We build a query to find the like of a given user that belongs to a given post
        let query = PFQuery(className: ParseLikeClass)
        query.whereKey(ParseLikeFromUser, equalTo: user)
        query.whereKey(ParseLikeToPost, equalTo: post)
        
        query.findObjectsInBackgroundWithBlock {
            (results: [AnyObject]?, error: NSError?) -> Void in
            // We iterate over all like objects that met our requirements and delete them.
            if let results = results as? [PFObject] {
                for likes in results {
                    likes.deleteInBackgroundWithBlock(nil)
                }
            }
        }
    }
    
    
    static func likesForPost(post: Post, completionBlock: PFArrayResultBlock) {
        let query = PFQuery(className: ParseLikeClass)
        query.whereKey(ParseLikeToPost, equalTo: post)
        // We are using the includeKey method to tell Parse to fetch the PFUser object for each of the likes (we've discussed includeKey in detail when building the timeline request). Otherwise, just reference.
        query.includeKey(ParseLikeFromUser)
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    
    
    // Following Relation
    static let ParseFollowClass = "Follow"
    static let ParseFollowFromUser = "fromUser"
    static let ParseFollowToUser = "toUser"
    
    // Like Relation
    static let ParseLikeClass = "Like"
    static let ParseLikeToPost = "toPost"
    static let ParseLikeFromUser = "fromUser"
    
    // Post Relation
    static let ParsePostUser = "user"
    static let ParsePostCreatedAt = "createdAt"
    
    // Flagged Content Relation
    static let ParseFlaggedContentClass = "FlaggedContent"
    static let ParseFlaggedContentFromUser = "fromUser"
    static let ParseFlaggedContentToPost = "toPost"
    
    // User Relation
    static let ParseUserUsername = "username"
    
    
    // We mark this method as static. This means we can call it without having to create an instance of ParseHelper - you should do that for all helper methods. This method has only one parameter, completionBlock: the callback block that should be called once the query has completed. The type of this parameter is PFArrayResultBlock. That's the default type for all of the callbacks in the Parse framework. By taking this callback as a parameter, we can call any Parse method and return the result of the method to that completionBlock - you'll see how we use that in 3.
    
    // As discussed, we modify the method signature to accept a Range argument. That Range argument will define which portions of the timeline will be loaded. Ranges in Swift are defined like this: 5..10.

    static func timelineRequestforCurrentUser(range: Range<Int>, completionBlock: PFArrayResultBlock) {
        let followingQuery = PFQuery(className: ParseFollowClass)
        followingQuery.whereKey(ParseLikeFromUser, equalTo:PFUser.currentUser()!)
        
        let postsFromFollowedUsers = Post.query()
        postsFromFollowedUsers!.whereKey(ParsePostUser, matchesKey: ParseFollowToUser, inQuery: followingQuery)
        
        let postsFromThisUser = Post.query()
        postsFromThisUser!.whereKey(ParsePostUser, equalTo: PFUser.currentUser()!)
        
        let query = PFQuery.orQueryWithSubqueries([postsFromFollowedUsers!, postsFromThisUser!])
        query.includeKey(ParsePostUser)
        query.orderByDescending(ParsePostCreatedAt)
        
        // PFQuery provides a skip property. That allows us - as the name lets us suspect - to define how many elements that match our query shall be skipped. This is the equivalent of the startIndex of our range, so all we need to do is a simple assignment.

        query.skip = range.startIndex
        // We make use of an additional property of PFQuery: limit. The limit property defines how many elements we want to load. We calculate the size of the range (by subtracting the startIndex from the endIndex) and pass the result to the limit property.

        query.limit = range.endIndex - range.startIndex
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
}