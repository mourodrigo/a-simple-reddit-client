//
//  PostCollectionViewCell.swift
//  a-simple-reddit-client
//
//  Created by Rodrigo Bueno Tomiosso on 08/02/17.
//  Copyright © 2017 mourodrigo. All rights reserved.
//

import UIKit

class PostCollectionViewCell: UICollectionViewCell {
    
    var post:Post?
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var dateAgoLabel: UILabel!
    @IBOutlet var commentsLabel: UILabel!
    @IBOutlet weak var viewedImageView: UIImageView!
    
    @IBAction func didTapDismissPost(_ sender: Any) {
        NotificationCenter.default.post(name: .didTapDismissPost, object: post)
    }
}

