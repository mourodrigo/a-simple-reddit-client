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
    
    init(let _title: String ,let _author: String ,let _date: Date ,let _externalURL: URL ,let _thumbnailURL: URL? ,let _commentsCount: Bool ,let _isReaded: Bool) {

        self.title = _title
        self.author = _author
        self.date = _date
        self.externalURL = _externalURL
        self.thumbnailURL = _thumbnailURL
        self.commentsCount = _commentsCount
        self.isReaded = _isReaded

    }
        
}
