//
//  PostCollectionViewCell.swift
//  a-simple-reddit-client
//
//  Created by Rodrigo Bueno Tomiosso on 08/02/17.
//  Copyright © 2017 mourodrigo. All rights reserved.
//

import UIKit

class PostCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var dateAgoLabel: UILabel!
    @IBOutlet var commentsLabel: UILabel!

    @IBAction func didTapImageButton(_ sender: Any) {
        NotificationCenter.default.post(name:.didTapImageButton, object: self.imageView.tag, userInfo: nil)
    }
        
}

