//
//  FullScreenImageViewController.swift
//  a-simple-reddit-client
//
//  Created by Rodrigo Bueno Tomiosso on 09/02/17.
//  Copyright © 2017 mourodrigo. All rights reserved.
//

import UIKit

class FullScreenImageViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var imageView: UIImageView!
    
    var urlString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.scrollView.minimumZoomScale = 1
        self.scrollView.maximumZoomScale = 3.5
        self.scrollView.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }

    override func viewWillAppear(_ animated: Bool) {
        imageView.downloadedFrom(link: urlString)
    }

    @IBAction func didTapSaveButton(_ sender: Any) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(imageDidSaveToPhotosWithSuccess(notification:)), name: .imageDidSaveToPhotosWithSuccess, object: nil)
 
        NotificationCenter.default.addObserver(self, selector: #selector(imageDidSaveToPhotosWithFail(notification:)), name: .imageDidSaveToPhotosWithFail, object: nil)

        
        self.imageView.saveToPhotos()
    }
    
    
    func imageDidSaveToPhotosWithSuccess(notification:Notification) -> Void {
        NotificationCenter.default.removeObserver(self, name: .imageDidSaveToPhotosWithSuccess, object: nil)
        NotificationCenter.default.removeObserver(self, name: .imageDidSaveToPhotosWithFail, object: nil)
        
        let alert = UIAlertController(title: nil, message: NSLocalizedString("Image saved", comment: "Image was saved to camera roll"), preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: NSLocalizedString("Thanks!", comment: "Option from alert controller"), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancel button pressed")
        })
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true) {
            print("errorAlert presented")
        }
    }
    
    func imageDidSaveToPhotosWithFail(notification:Notification) -> Void {
        NotificationCenter.default.removeObserver(self, name: .imageDidSaveToPhotosWithSuccess, object: nil)
        NotificationCenter.default.removeObserver(self, name: .imageDidSaveToPhotosWithFail, object: nil)
        
        var bodyAlert = ""
        
        if(notification.object != nil){
            bodyAlert = bodyAlert.appending(notification.object as! String)
        }
        
        let alert = UIAlertController(title: nil, message: NSLocalizedString("Error not saved", comment: bodyAlert), preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: NSLocalizedString("Ok!", comment: "Option from alert controller"), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancel button pressed")
        })
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true) {
            print("errorAlert presented")
        }
    }

}
