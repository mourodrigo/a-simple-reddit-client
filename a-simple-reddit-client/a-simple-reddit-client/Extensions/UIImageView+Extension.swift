//
//  UIImageView+Extension.swift
//  a-simple-reddit-client
//
//  Created by Rodrigo Bueno Tomiosso on 08/02/17.
//  Copyright © 2017 mourodrigo. All rights reserved.
//

import Foundation
import UIKit
import Photos

extension UIImageView {
    
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
 
        let task = URLSession.shared.dataTask(with: url as URL) { (data, response, error) -> Void in
            
            if error == nil {
                DispatchQueue.main.async {
                    self.setImage(with: data!)
                }
            }

        }
        task.resume()
    }
    
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
    
    func setImage(with data:Data){
        let image = UIImage(data: data)
        self.image = image
    
    }

    func saveToPhotos(){
        
        PHPhotoLibrary.requestAuthorization { (status) in
            if (status == PHAuthorizationStatus.authorized){

                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: self.image!)
                }, completionHandler: { success, error in
                    if success {
                        NotificationCenter.default.post(name:.imageDidSaveToPhotosWithSuccess, object: nil, userInfo: nil)
                    }
                    else if error != nil {
                        NotificationCenter.default.post(name:.imageDidSaveToPhotosWithFail, object: error?.localizedDescription, userInfo: nil)
                    }
                })
                
            }else{
                NotificationCenter.default.post(name:.imageDidSaveToPhotosWithFail, object: "Please authorize Photo Library for saving this image", userInfo: nil)
            }
        }
        
    }
    
}
