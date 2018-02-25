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

    //UICollectionViewLayout
    var numberOfColumns = 1
    let spacing = 4
    var cellSize = CGSize.zero

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
        NotificationCenter.default.addObserver(self, selector: #selector(didTapImageButton(notification:)), name: .didTapImageButton, object: nil)
 
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
        self.updateCellSize()
        updateDataSource()
    
    }
    
    // MARK: UICollectionViewDataSource
    
    //MARK - ImagePreview
    
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

            delegate.postSelected(posts[indexPath.row])

            if let detailViewController = delegate as? PostDetailViewController { //shows detail view controller for iphone splitview
                splitViewController?.showDetailViewController(detailViewController, sender: nil)
            }
        }
    }
    
    // MARK: UICollectionViewLayout
    
    func updateCellSize(tofit size:CGSize = UIScreen.main.bounds.size){
        cellSize = self.getCellSize(tofit: size)  //calculates cell size
    }
    
    func getCellSize(tofit size:CGSize = UIScreen.main.bounds.size) -> CGSize{
        
        let contentSize = size
        
        if(UIDevice.current.model=="iPhone" && UIDevice.current.orientation.isPortrait){
            numberOfColumns = 1
        }else if(UIDevice.current.model=="iPhone" && UIDevice.current.orientation.isLandscape){
            numberOfColumns = 2
        }else if(UIDevice.current.model=="iPad" && UIDevice.current.orientation.isPortrait){
            numberOfColumns = 3
        }else if(UIDevice.current.model=="iPad" && (UIDevice.current.orientation.isLandscape || UIDevice.current.orientation.isFlat)){
            numberOfColumns = 4
        }else{
            numberOfColumns = 1
        }
        
        let cellWidth = CGFloat.init((Int(contentSize.width)-(numberOfColumns*spacing)) / numberOfColumns)
        return CGSize.init(width: cellWidth, height: cellWidth/2)  //calculate cell size
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(spacing)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(spacing)
    }

    //MARK: - Orientation
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.collectionView?.collectionViewLayout.invalidateLayout()
        self.updateCellSize(tofit: size)
    }
    
    //MARK - ImagePreview
    
    @objc func didTapImageButton(notification:Notification) -> Void {

        if(notification.object != nil){
            
            let index = IndexPath.init(row: (notification.object as! Int) , section: 0)
            
            let data = posts[index.row]
            
//            let previewData = data.value(forKey: "preview") as! NSDictionary
//            
//            if(previewData.value(forKey: "enabled") as! Bool){
//                
//                let images = previewData.value(forKey: "images") as! NSArray
//                let imageSource = images.value(forKey: "source") as! NSArray
//                let content = imageSource.firstObject as! NSDictionary
//                let urlString = content.value(forKey: "url") as! String
//                
//                self.performSegue(withIdentifier: "ShowFullScreenImageViewController", sender: urlString)
//                
//            }
        }
    }

    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if(segue.identifier == "ShowFullScreenImageViewController"){
            
            let urlString = sender as! String

            let fullScreenImageViewController = segue.destination as! FullScreenImageViewController
            fullScreenImageViewController.urlString = urlString
            
            
        }
        
        if(segue.identifier == "ShowWebViewController"){
            
            let urlString = sender as! String
            
            let webViewController = segue.destination as! WebViewController
            webViewController.urlString = urlString
            
            
        }
    
    }
   
}
