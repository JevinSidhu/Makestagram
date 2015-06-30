//
//  PhotoTakingHelper.swift
//  Makestagram
//
//  Created by Jevin Sidhu on 2015-06-30.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit

//Any function that wants to be the callback of the PhotoTakingHelper needs to have exactly this signature.
//A function of type PhotoTakingHelperCallback takes an UIImage? as parameter and returns Void. 

typealias PhotoTakingHelperCallback = UIImage? -> Void

class PhotoTakingHelper : NSObject {
    
    /** View controller on which AlertViewController and UIImagePickerController are presented */
    
    // Reference to view controller to present other view controllers
    
    weak var viewController: UIViewController!
    var callback: PhotoTakingHelperCallback
    var imagePickerController: UIImagePickerController?
    
    init(viewController: UIViewController, callback: PhotoTakingHelperCallback) {
        self.viewController = viewController
        self.callback = callback
        
        super.init()
        
    // Gallery or take photo?
    // Called in init, will act as soon as instance of PhotoTakingHelper created
        
        showPhotoSourceSelection()
    }
    
    func showPhotoSourceSelection() {
        // Allow user to choose between photo library and camera
        let alertController = UIAlertController(title: nil, message: "Where do you want to get your picture from?", preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // Only show camera option if rear camera is available
        if (UIImagePickerController.isCameraDeviceAvailable(.Rear)) {
            let cameraAction = UIAlertAction(title: "Photo from Camera", style: .Default) { (action) in
                // do nothing yet...
            }
            
            alertController.addAction(cameraAction)
        }
        
        let photoLibraryAction = UIAlertAction(title: "Photo from Library", style: .Default) { (action) in
            // do nothing yet...
        }
        
        alertController.addAction(photoLibraryAction)
        
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }
    
}