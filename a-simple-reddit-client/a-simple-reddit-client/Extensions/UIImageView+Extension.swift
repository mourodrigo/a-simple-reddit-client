//
//  UIImageView+Extension.swift
//  a-simple-reddit-client
//
//  Created by Rodrigo Bueno Tomiosso on 08/02/17.
//  Copyright © 2017 mourodrigo. All rights reserved.
//

import Foundation
import UIKit

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
}
