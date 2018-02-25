//
//  Posts.swift
//  a-simple-reddit-client
//
//  Created by Rodrigo Bueno Tomiosso on 24/02/2018.
//  Copyright © 2018 mourodrigo. All rights reserved.
//

import Foundation

class Post {
    let name: String
    let title: String
    let author: String
    let date: Date?
    let externalLink: String?
    let thumbnailLink: String?
    let commentsCount: Int
    let isReaded: Bool
    
    init(_name:String, _title: String, _author: String, _date: Date?, _externalLink: String?, _thumbnailLink: String?, _commentsCount: Int  , _isReaded: Bool) {

        self.name = _name
        self.title = _title
        self.author = _author
        self.date = _date
        self.externalLink = _externalLink
        self.thumbnailLink = _thumbnailLink
        self.commentsCount = _commentsCount
        self.isReaded = _isReaded

    }
    
    class func fetch(after postId:String = ""){
        
        guard let url = URL(string: "http://oauth.reddit.com/top/.json?".appending(postId)) else { return }
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.setValue("Bearer \(Authorization.sharedInstance.token.value(forKey: "access_token") as! String)", forHTTPHeaderField: "Authorization")
        
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        request.timeoutInterval = 30
        
        let task = session.dataTask(with: request) { ( data, response, error) in
            
            if(error != nil){
                print("AN ERROR OCURRED")
            }
            
            do {
                
                let JSONReturn = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [AnyHashable : AnyObject]
                
                if let data = JSONReturn["data"], let childrens = data["children"] as? Array<[String : AnyObject]> {
                    
                    var posts = [Post]()
                    
                    for child in childrens {
                        if let item = child["data"] {
                                    let newPost = Post(_name: item["name"] as? String ?? "",

                                               _title: item["title"] as? String ?? "",
                                               
                                               _author: item["author"] as? String ?? "",
                                               
                                               _date: item["created_utc"] != nil ? Date.init(timeIntervalSince1970: (item["created_utc"] as! TimeInterval)) : nil,
                                               
                                               _externalLink: item["url"] as? String,
                                               
                                               _thumbnailLink: item["thumbnail"] as? String,
                                               
                                               _commentsCount: item["num_comments"] as! Int,
                                               
                                               _isReaded: false)
                            
                            posts.append(newPost)
                        }
                    }
                        NotificationCenter.default.post(name: .didFetchPosts, object: posts, userInfo: nil)
            }
                
            }
            catch {
                NotificationCenter.default.post(name:.oAuthDidFail, object: nil, userInfo: nil)
            }
        }
        
        task.resume()
        
    }
    
}
