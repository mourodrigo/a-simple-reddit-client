//
//  Date+Extension.swift
//  a-simple-reddit-client
//
//  Created by Rodrigo Bueno Tomiosso on 08/02/17.
//  Copyright © 2017 mourodrigo. All rights reserved.
//

import Foundation
extension Date {
    
    func isPassed() -> Bool {
        if self.compare(Date()) == ComparisonResult.orderedDescending {
            return false
        }else{
            return true
        }
    }
    
}
