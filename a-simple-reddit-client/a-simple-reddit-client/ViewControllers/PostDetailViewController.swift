//
//  PostDetailViewController.swift
//  a-simple-reddit-client
//
//  Created by Rodrigo Bueno Tomiosso on 24/02/2018.
//  Copyright © 2018 mourodrigo. All rights reserved.
//

import UIKit

class PostDetailViewController: UIViewController {

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postDetailTextLabel: UITextView!
    
    var post: Post? {
        didSet {
            refreshUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.postImageView.isUserInteractionEnabled = true
        self.view.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapImageView))
        postImageView.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func didTapImageView() {
        guard let link = post?.thumbnailLink, link.isURL else { return }
        self.performSegue(withIdentifier: "ShowFullScreenImageViewController", sender: nil)
    }
    
    func refreshUI() {
        loadViewIfNeeded()
        postTitleLabel.text = post?.author
        postDetailTextLabel.text = post?.title
        if let link = post?.thumbnailLink, link.isURL {
            postImageView.downloadedFrom(link: link)
        } else {
            postImageView.image = UIImage.init(named: "externalLink")
        }
    }


    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowFullScreenImageViewController" {
            let fullScreenImageViewController = segue.destination as! FullScreenImageViewController
            fullScreenImageViewController.urlString = (post?.thumbnailLink)!
        }

    }
    
}

extension PostDetailViewController: PostSelectionDelegate {
    func postSelected(_ postSelected: Post) {
        post = postSelected
    }
}

