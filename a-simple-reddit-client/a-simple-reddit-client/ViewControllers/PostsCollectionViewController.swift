//
//  PostsCollectionViewController.swift
//  a-simple-reddit-client
//
//  Created by Rodrigo Bueno Tomiosso on 08/02/17.
//  Copyright © 2017 mourodrigo. All rights reserved.
//

import UIKit

class PostsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    //UICollectionViewLayout
    var numberOfColumns = 1
    let spacing = 4
    var cellSize = CGSize.zero

    //Loading and Refresh
    @IBOutlet var backgroundView: UIView!
    let refresher = UIRefreshControl()
 
    //Datasource
    var posts: NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView!.alwaysBounceVertical = true
        refresher.addTarget(self, action: #selector(updateDataSource), for: .valueChanged)
        collectionView!.addSubview(refresher)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didTapImageButton(notification:)), name: .didTapImageButton, object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateDataSource()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.updateCellSize()
    }
    
    // MARK: UICollectionViewDataSource
    
    func updateDataSource(){
        
        self.refresher.beginRefreshing()
        fetchPosts()
        
    }
    
    func fetchPosts(after:String = ""){
        
        let url = URL(string: "https://www.reddit.com/top/.json?".appending(after))!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData

        request.timeoutInterval = 30
        
        let task = session.dataTask(with: request) { ( data, response, error) in
            
            if(error != nil){
                print("AN ERROR OCURRED")
            }
            
            do {
                
                let JSONReturn = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [AnyHashable : AnyObject]
                
                let postsArray = JSONReturn["data"]?["children"] as! Array<[String : AnyObject]>
                self.posts.addObjects(from: postsArray)
               
                DispatchQueue.main.async {
                    self.refresher.endRefreshing()
                    self.backgroundView.isHidden = true
                    self.collectionView?.reloadData()
                }
                
            }
            catch {
                NotificationCenter.default.post(name:.oAuthDidFail, object: nil, userInfo: nil)
            }
        }
        
        task.resume()
        
    }
    
    func dataFor(indexPath: IndexPath, offset:Int = 0) -> NSDictionary{
        
        let content = self.posts[indexPath.row+offset] as! NSDictionary
        return content.value(forKey: "data") as! NSDictionary

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

        if(indexPath.row == self.posts.count){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoadMoreCollectionViewCell", for: indexPath) as! LoadMoreCollectionViewCell
            return cell
            
        }else{
            
            let data = dataFor(indexPath: indexPath)
           
            let thumbnail = data.value(forKey: "thumbnail") as! String
            
            var reuseIdentifier = ""
            var image:UIImage?
            
            if(thumbnail.isURL){
                reuseIdentifier = "PostCollectionViewCell"
                
            }else{
                image = UIImage.init(named: "imageIcon")
                reuseIdentifier = "NoImagePostCollectionViewCell"
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PostCollectionViewCell
            
            cell.authorLabel.text = data.value(forKey: "author") as? String

            cell.titleLabel.text = data.value(forKey: "title")  as? String

            cell.commentsLabel.text = String.init(format: "%d comments", data.value(forKey: "num_comments") as! Int)

            let date = data.value(forKey: "created_utc") as! TimeInterval

            cell.dateAgoLabel.text = Date.init(timeIntervalSince1970: date).timeAgoString()

            if(image==nil){
                cell.imageView.tag = indexPath.row
                cell.imageView.downloadedFrom(link: thumbnail)
            }else{
                cell.imageView.image = image
            }
            
            return cell

        }
    
    }
    
    
    // MARK: UICollectionViewDataDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        if(indexPath.row == posts.count && !refresher.isRefreshing){ // the load more label

            let data = dataFor(indexPath: indexPath, offset: -1)
            
            let after = data.value(forKey: "name") as! String
            
            self.fetchPosts(after: "count=\(self.posts.count)&after=\(after)")

        }else{ // any other cell will open a webview with URL  

            let data = dataFor(indexPath: indexPath)
            
            let urlString = data.value(forKey: "url") as! String
            
            self.performSegue(withIdentifier: "ShowWebViewController", sender: urlString)
            
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
        return CGSize.init(width: cellWidth, height: cellWidth/3)  //calculate cell size
        
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
    
    func didTapImageButton(notification:Notification) -> Void {

        if(notification.object != nil){
            
            let index = IndexPath.init(row: (notification.object as! Int) , section: 0)
            
            let data = dataFor(indexPath: index)
            
            let previewData = data.value(forKey: "preview") as! NSDictionary
            
            if(previewData.value(forKey: "enabled") as! Bool){
                
                let images = previewData.value(forKey: "images") as! NSArray
                let imageSource = images.value(forKey: "source") as! NSArray
                let content = imageSource.firstObject as! NSDictionary
                let urlString = content.value(forKey: "url") as! String
                
                self.performSegue(withIdentifier: "ShowFullScreenImageViewController", sender: urlString)
                
            }
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
