//
//  CustomPostsNavigationController.swift
//  a-simple-reddit-client
//
//  Created by Rodrigo Bueno Tomiosso on 25/02/2018.
//  Copyright © 2018 mourodrigo. All rights reserved.
//

import UIKit

class CustomPostsNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        UINavigationBar.appearance().barTintColor = UIColor.black
        UINavigationBar.appearance().backgroundColor = UIColor.white
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        UITabBar.appearance().tintColor = UIColor.white
        UIBarButtonItem.appearance().tintColor = UIColor.white

    }
}
