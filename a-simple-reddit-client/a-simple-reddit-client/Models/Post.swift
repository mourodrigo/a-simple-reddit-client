//
//  Posts.swift
//  a-simple-reddit-client
//
//  Created by Rodrigo Bueno Tomiosso on 24/02/2018.
//  Copyright © 2018 mourodrigo. All rights reserved.
//

import Foundation

class Post {
    let title: String
    let author: String
    let date: Date
    let externalURL: URL
    let thumbnailURL: URL?
    let commentsCount: Bool
    let isReaded: Bool
    
    init(_title: String, _author: String, _date: Date, _externalURL: URL, _thumbnailURL: URL?, _commentsCount: Bool, _isReaded: Bool) {

        self.title = _title
        self.author = _author
        self.date = _date
        self.externalURL = _externalURL
        self.thumbnailURL = _thumbnailURL
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
                
                if let data = JSONReturn["data"], let items = data["children"] as? Array<[String : AnyObject]> {
                    NotificationCenter.default.post(name: .didFetchPosts, object: items, userInfo: nil)
                }
                
            }
            catch {
                NotificationCenter.default.post(name:.oAuthDidFail, object: nil, userInfo: nil)
            }
        }
        
        task.resume()
        
    }
    
}
