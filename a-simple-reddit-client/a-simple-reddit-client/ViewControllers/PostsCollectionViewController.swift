//
//  PostsCollectionViewController.swift
//  a-simple-reddit-client
//
//  Created by Rodrigo Bueno Tomiosso on 08/02/17.
//  Copyright © 2017 mourodrigo. All rights reserved.
//

import UIKit

protocol PostSelectionDelegate: class {
    func postSelected(_ post: Post)
}

class PostsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    //Loading and Refresh
    @IBOutlet var backgroundView: UIView!
    let refresher = UIRefreshControl()
 
    //Datasource
    var posts = [Post]()
    
    //Delegate
    weak var postDetailDelegate: PostSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //notifications for token authorization
        NotificationCenter.default.addObserver(self, selector: #selector(presentUserLoginControll(notification:)), name: .oAuthDidFail, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presentUserLoginControll(notification:)), name: .oAuthNeedsUserLogin, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateDataSource), name: .tokenDidAuthorize, object: nil)
        
        //notifications for user actions
        NotificationCenter.default.addObserver(self, selector: #selector(didTapDismissPost(notification:)), name: .didTapDismissPost, object: nil)
 
        //notifications for user actions
        NotificationCenter.default.addObserver(self, selector: #selector(didFetchPosts(notification:)), name: .didFetchPosts, object: nil)
        
        //refresh controller for pull-to-refresh on collectionview
        self.collectionView!.alwaysBounceVertical = true
        refresher.addTarget(self, action: #selector(updateDataSource), for: .valueChanged)
        collectionView!.addSubview(refresher)
        
    }
    
    // MARK: User Authentication
    
    @objc func presentUserLoginControll(notification:Notification) -> Void {
        self.performSegue(withIdentifier: "PresentLoginViewController", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if posts.count == 0 {
            updateDataSource()
        }
    
    }
    
    // MARK: UICollectionViewDataSource
    
    @objc func didFetchPosts(notification:Notification) -> Void {
        
        if let postsFetched = notification.object as? [Post] {
            self.posts.append(contentsOf: postsFetched)
            DispatchQueue.main.async {
                self.refresher.endRefreshing()
                self.backgroundView.isHidden = true
                self.collectionView?.reloadData()
            }
        }
    }
    
    @objc func updateDataSource(){
        if Authorization.sharedInstance.token.allKeys.count>0 {
            self.refresher.beginRefreshing()
            Post.fetch()
        } else {
            Authorization.sharedInstance.authorize()
        }

    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if ( refresher.isRefreshing || posts.count == 0) {
            return posts.count
        }
        if ( !refresher.isRefreshing ) {
            return posts.count+1 //for load more label at the bottom
        }
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.row == self.posts.count {
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoadMoreCollectionViewCell", for: indexPath) as! LoadMoreCollectionViewCell
            return cell

        } else {
            
            let post = posts[indexPath.row]
           
            var reuseIdentifier = "NoImagePostCollectionViewCell"
            
            if let thumbnailLink = post.thumbnailLink, thumbnailLink.isURL {
                reuseIdentifier = "PostCollectionViewCell"
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PostCollectionViewCell
            
            cell.post = post

            cell.authorLabel.text = post.author

            cell.titleLabel.text = post.title

            cell.commentsLabel.text = "\(post.commentsCount) comments"
            
            cell.viewedImageView.isHidden = post.isReaded

            if let postDate = post.date {
                cell.dateAgoLabel.text = postDate.timeAgoString()
            } else {
                cell.dateAgoLabel.text = ""
            }

            if let thumbnailLink = post.thumbnailLink, thumbnailLink.isURL {
                cell.imageView.downloadedFrom(link: thumbnailLink)
            }
            
            return cell
        }
    }

    // MARK: UICollectionViewDataDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == posts.count && !refresher.isRefreshing { // load more label

            Post.fetch(after: "count=\(self.posts.count)&after=\(posts[indexPath.row-1].name)")

        } else if let delegate = postDetailDelegate {
            
                //updates post readed status and post cell
                collectionView.performBatchUpdates({
                    posts[indexPath.row].isReaded = true
                    collectionView.reloadItems(at: [indexPath])
                }, completion: { (bool) in
                    
                    //send post to detail view controller
                    delegate.postSelected(self.posts[indexPath.row])
                    
                    //shows detail view controller for iphone splitview
                    if let detailViewController = delegate as? PostDetailViewController {
                        self.splitViewController?.showDetailViewController(detailViewController, sender: nil)
                    }
                    
                })

        }
    }

    //MARK: - Post Dismiss
    
    @objc func didTapDismissPost(notification:Notification) -> Void {
        guard let post = notification.object as? Post else { return }
        print("post to delete", post.name)
        if let index = posts.index(where: { (postItem) -> Bool in
            postItem.name == post.name
        }) {
            print("post deleted", posts[index].name)
            self.collectionView?.performBatchUpdates({
                posts.remove(at: index)
                self.collectionView?.deleteItems(at: [IndexPath.init(item: index, section: 0)])
            }, completion: nil)
        }
    }
    
    @IBAction func didTapDismissAllPost(_ sender: Any) {
        self.posts.removeAll()
        self.collectionView?.performBatchUpdates({
            self.collectionView?.reloadSections(IndexSet.init(integer: 0))
        }, completion: nil)

    }

}
