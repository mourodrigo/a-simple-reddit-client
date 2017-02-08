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

    @IBOutlet var backgroundView: UIView!
    
    var posts: Array<[AnyHashable : AnyObject]> = []

    let refresher = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
    
        self.collectionView!.alwaysBounceVertical = true
        refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        collectionView!.addSubview(refresher)
 
        
    }

    func loadData(){
        self.refresher.beginRefreshing()
        fetchPosts()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadData()
    }
        
    func fetchPosts(){
     
        let url = URL(string: "https://www.reddit.com/top/.json")!
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
                
                self.posts = JSONReturn["data"]?["children"] as! Array<[String : AnyObject]>
               
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

        let thumbnail = data["thumbnail"] as! String
        
        if(thumbnail.isURL){
            
            cell.imageView.downloadedFrom(link: thumbnail)
            
        }else{

            print("not URL")
        }
        
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
