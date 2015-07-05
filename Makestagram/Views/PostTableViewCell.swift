//
//  PostTableViewCell.swift
//  Makestagram
//
//  Created by Jevin Sidhu on 2015-07-04.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Bond
import Parse

class PostTableViewCell: UITableViewCell {
    
    // Generates a comma separated list of usernames from an array (e.g. "User1, User2")
    func stringFromUserList(userList: [PFUser]) -> String {
        // You have already seen and used map before. As we discussed it allows you to replace objects in a collection with other objects. Typically you use map to create a different representation of the same thing. In this case we are mapping from PFUser objects to the usernames of these PFObjects.

        let usernameList = userList.map { user in user.username! }
        // We now use that array of strings to create one joint string. We can do that by using the join method provided by Swift. We first need to define the delimiter (", " in our case) and can the call the join method on it. The join method takes an array of strings. After this method is called, we have created a string of the following form: "Test User 1, Test User 2".

        let commaSeparatedUserList = ", ".join(usernameList)
        
        return commaSeparatedUserList
    }
    
    var likeBond: Bond<[PFUser]?>!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // The unowned keyword works similar to the weak keyword - we store a reference to self, but it isn't a strong reference that would keep the object in memory.
        likeBond = Bond<[PFUser]?>() { [unowned self] likeList in
            // As a reminder: this code runs as soon as the value of likes on a Post changes. First, we check whether we have received a value for likeList or if we have received nil.

            if let likeList = likeList {
                // If we have received a value, we perform different updates. First of all, we update the likesLabel to display a list of usernames of all users that have liked the post. We use a utility method stringFromUserList to generate that list. We'll add and discuss that method later on!

                self.likesLabel.text = self.stringFromUserList(likeList)
                // Next, we set the state of the like button (the heart) based on whether or not the current user is in the list of users that like the currently displayed post. If the user has liked the post, we want the button to be in the Selected state so that the heart appears red. If not selected will be set to false and the heart will be displayed in gray.

                self.likesButton.selected = contains(likeList, PFUser.currentUser()!)
                // Finally, if no one likes the current post, we want to hide the small heart icon displayed in front of the list of users that like a post.
                self.likesIconImageView.hidden = (likeList.count == 0)
            } else {
                // If the value we have received in likeList is nil, we set the label text to be empty, set the like button not to be selected and hide the small heart icon.
                // if there is no list of users that like this post, reset everything
                self.likesLabel.text = ""
                self.likesButton.selected = false
                self.likesIconImageView.hidden = true
            }
        }
    }

    @IBOutlet weak var postImageView: UIImageView!

    @IBOutlet weak var likesIconImageView: UIImageView!
    
    @IBOutlet weak var likesLabel: UILabel!

    @IBOutlet weak var likesButton: UIButton!
    
    
    @IBOutlet weak var moreButton: UIButton!
    
    
    @IBAction func likeButtonTapped(sender: AnyObject) {
        post?.toggleLikePost(PFUser.currentUser()!)
    }
    
    @IBAction func moreButtonTapped(sender: AnyObject) {
    }
    
    var post:Post? {
        
        
        didSet {
            // Whenever a new value is assigned to the post property, we use optional binding to check whether the new value is nil.
            if let post = post {
                
        /* If the value isn't nil, we create a binding between the image property of the post and the postImageView using the ->> operator. The Bond library has special support for many UI components, including the UIImageView.
                
            This support allows us to bind an UIImage (post.image) directly to a UIImageView
                (postImageView) - whenever post.image updates, the displayed image of postImageView will update magically.*/

                // bind the image of the post to the 'postImage' view
                post.image ->> postImageView
                
                // bind the likeBond that we defined earlier, to update like label and button when likes change
                post.likes ->> likeBond
            }
        }
    }
    
        override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension PFObject : Equatable { }

public func ==(lhs: PFObject, rhs: PFObject) -> Bool {
    return lhs.objectId == rhs.objectId }
