//
//  Notification+Extension.swift
//  a-simple-reddit-client
//
//  Created by Rodrigo Bueno Tomiosso on 07/02/17.
//  Copyright © 2017 mourodrigo. All rights reserved.
//

import Foundation

extension Notification.Name {

    static let oAuthDidReturn = Notification.Name("oAuthDidReturn")
    static let oAuthDidFail = Notification.Name("oAuthDidFail")
    static let tokenDidAuthorize = Notification.Name("tokenDidAuthorize")
    static let oAuthNeedsUserLogin = Notification.Name("oAuthNeedsUserLogin")
    
    static let imageDidSaveToPhotosWithSuccess = Notification.Name("imageDidSaveToPhotosWithSuccess")
    static let imageDidSaveToPhotosWithFail = Notification.Name("imageDidSaveToPhotosWithFail")

    static let didTapImageButton = Notification.Name("didTapImageButton")

}
