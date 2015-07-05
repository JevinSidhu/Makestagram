//
//  TimelineViewController.swift
//  Makestagram
//
//  Created by Jevin Sidhu on 2015-06-30.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Parse

class TimelineViewController: UIViewController {
    
    var posts: [Post] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    var photoTakingHelper: PhotoTakingHelper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        ParseHelper.timelineRequestforCurrentUser {
        (result: [AnyObject]?, error: NSError?) -> Void in
        
            self.posts = result as? [Post] ?? []
            
        // Once we have stored the new posts, we refresh the tableView.
            self.tableView.reloadData()
            
        }
    }
    
    func takePhoto() {
        // instantiate photo taking class, provide callback for when photo is selected
        photoTakingHelper =
            PhotoTakingHelper(viewController: self.tabBarController!) { (image: UIImage?) in
                let post = Post()
                post.image.value = image!
                post.uploadPost()
        }
    }
    
}

// MARK: Tab Bar Delegate

extension TimelineViewController: UITabBarControllerDelegate {
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if (viewController is PhotoViewController) {
            takePhoto()
            return false
        } else {
            return true
        }
    }
    
}

extension TimelineViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Our Table View needs to have as many rows as we have posts stored in the posts property
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // In this line we have added a cast to PostTableViewCell. In Storyboard we've configured a custom class for our Table View Cell. In order to access its specific properties we need to perform a cast to the type of our custom class. Without this cast the cell variable would have a type of a plain old UITableViewCell instead of our PostTableViewCell.

        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell
        let post = posts[indexPath.row]

        // Directly before a post will be displayed, we trigger the image download.

        post.downloadImage()
        post.fetchLikes()
    
        // Instead of changing the image that is displayed in the cell from within the TimelineViewController, we assign the post that shall be displayed to the post property. After the changes we made a few steps back, the cell now takes care of displaying the image that belongs to a Post object itself.

        cell.post = post
        
        return cell
    }
    
}