//
//  PostsCollectionViewController.swift
//  a-simple-reddit-client
//
//  Created by Rodrigo Bueno Tomiosso on 08/02/17.
//  Copyright © 2017 mourodrigo. All rights reserved.
//

import UIKit

class PostsCollectionViewController: UICollectionViewController {

    @IBOutlet var backgroundView: UIView!
    
    var posts: NSMutableArray = []

    let refresher = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView!.alwaysBounceVertical = true
        refresher.addTarget(self, action: #selector(updateDataSource), for: .valueChanged)
        collectionView!.addSubview(refresher)
        
    }

    func updateDataSource(){
        self.refresher.beginRefreshing()
        fetchPosts()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateDataSource()
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
    
   // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
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
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCollectionViewCell", for: indexPath) as! PostCollectionViewCell
            
            let content = self.posts[indexPath.row] as! NSDictionary
            
            let data = content.value(forKey: "data") as! NSDictionary
            
            cell.authorLabel.text = data.value(forKey: "author") as? String

            cell.titleLabel.text = data.value(forKey: "title")  as? String

            cell.commentsLabel.text = String.init(format: "%d comments", data.value(forKey: "num_comments") as! Int)

            let date = data.value(forKey: "created_utc") as! TimeInterval

            cell.dateAgoLabel.text = Date.init(timeIntervalSince1970: date).timeAgoString()

            let thumbnail = data.value(forKey: "thumbnail") as! String
            
            if(thumbnail.isURL){
                
                cell.imageView.downloadedFrom(link: thumbnail)
                
            }else{

                cell.imageView.image = UIImage.init(named: "imageIcon")

            }
            
            return cell
        }
    
    }
    

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if(indexPath.row == posts.count && !refresher.isRefreshing){ // the load more label
            let content = self.posts[indexPath.row-1] as! NSDictionary
            
            let data = content.value(forKey: "data") as! NSDictionary
            
            let after = data.value(forKey: "name") as! String
            
            self.fetchPosts(after: "count=\(self.posts.count)&after=\(after)")
        }
        
    }
    
   
}
