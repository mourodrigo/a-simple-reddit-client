//
//  PostsCollectionViewController.swift
//  a-simple-reddit-client
//
//  Created by Rodrigo Bueno Tomiosso on 08/02/17.
//  Copyright © 2017 mourodrigo. All rights reserved.
//

import UIKit

private let reuseIdentifier = "PostCollectionViewCell"

class PostsCollectionViewController: UICollectionViewController {

    var posts: Array<[AnyHashable : AnyObject]> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        fetchPosts()
    }
    
    func fetchPosts(){
     
        let url = URL(string: "https://www.reddit.com/top/.json")!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        let task = session.dataTask(with: request) { ( data, response, error) in
            
            do {
                
                let JSONReturn = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [AnyHashable : AnyObject]
                
                self.posts = JSONReturn["data"]?["children"] as! Array<[String : AnyObject]>
                self.collectionView?.reloadData()
                
            }
            catch {
                NotificationCenter.default.post(name:.oAuthDidFail, object: nil, userInfo: nil)
            }
        }
        
        task.resume()
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PostCollectionViewCell
        
        let post = self.posts[indexPath.row]
        let data = post["data"] as! [String : AnyObject]

        cell.authorLabel.text = data["author"] as? String
        
        cell.titleLabel.text = data["title"]  as? String

        cell.commentsLabel.text = String.init(format: "%d comments", data["num_comments"] as! Int)

        let date = data["created_utc"] as! TimeInterval

        cell.dateAgoLabel.text = Date.init(timeIntervalSince1970: date).timeAgoString()

        cell.imageView.downloadedFrom(link: data["thumbnail"] as! String)
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
