//
//  TimelineViewController.swift
//  Makestagram
//
//  Created by Jevin Sidhu on 2015-06-30.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Parse
import ConvenienceKit

class TimelineViewController: UIViewController, TimelineComponentTarget {
    
    var timelineComponent: TimelineComponent<Post, TimelineViewController>!

    
    func loadInRange(range: Range<Int>, completionBlock: ([Post]?) -> Void) {
        ParseHelper.timelineRequestforCurrentUser(range) {
            (result: [AnyObject]?, error: NSError?) -> Void in
            
            let posts = result as? [Post] ?? []
            completionBlock(posts)
        }
    }
    
    let defaultRange = 0...4
    let additionalRangeSize = 5
    
    @IBOutlet weak var tableView: UITableView!
    
    var photoTakingHelper: PhotoTakingHelper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timelineComponent = TimelineComponent(target: self)
        self.tabBarController?.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        timelineComponent.loadInitialIfRequired()
        self.tabBarController?.delegate = self

    }
    
    func takePhoto() {
        // Instantiate photo taking class, provide callback for when photo is selected
        photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!) { (image: UIImage?) in
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.timelineComponent.content.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell
        
        let post = timelineComponent.content[indexPath.section]
        post.downloadImage()
        post.fetchLikes()
        cell.post = post
        
        return cell
    }
}

    extension TimelineViewController: UITableViewDelegate {
        
        func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
            
            timelineComponent.targetWillDisplayEntry(indexPath.section)
        }
        
        func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let headerCell = tableView.dequeueReusableCellWithIdentifier("PostHeader") as! PostSectionHeaderView
            
            let post = self.timelineComponent.content[section]
            headerCell.post = post
            
            return headerCell
        }
        
        func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 40
        }
        
}