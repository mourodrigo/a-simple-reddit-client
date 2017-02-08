//
//  Notification+Extension.swift
//  a-simple-reddit-client
//
//  Created by Rodrigo Bueno Tomiosso on 07/02/17.
//  Copyright © 2017 mourodrigo. All rights reserved.
//

import Foundation
import UIKit

extension String {

    var componentsFromQueryString: [String : String] {
        
        var components = [String: String]()
        
            for qs in self.components(separatedBy: "&") {

                let key = qs.components(separatedBy: "=")[0]
                
                var value = qs.components(separatedBy: "=")[1]
               
                value = value.replacingOccurrences(of: "+", with: " ")
                
                value = value.removingPercentEncoding!
                
                components[key] = value
            }
        
        return components
    }
    
    var isURL: Bool {
        // create NSURL instance
        if let url = NSURL(string: self) {
            // check if your application can open the NSURL instance
            return UIApplication.shared.canOpenURL(url as URL)
        }
        return false
    }
    
}
