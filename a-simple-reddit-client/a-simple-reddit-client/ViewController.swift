//
//  ViewController.swift
//  a-simple-reddit-client
//
//  Created by Rodrigo Bueno Tomiosso on 07/02/17.
//  Copyright © 2017 mourodrigo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didPressLoginButton(_ sender: AnyObject) {
        self.login()
    }
    
    func login(){
        NotificationCenter.default.addObserver(self, selector: #selector(tokenDidAuthorize(notification:)), name: .tokenDidAuthorize, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(oAuthDidFail), name: .oAuthDidFail, object: nil)

        Authorization.sharedInstance.prepareForAuthorize()
        self.openOnBrowser(url: Authorization.sharedInstance.authURL())

    }
    
    func openOnBrowser(url: String) {
        if let url = URL(string: url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                    print("Open \(url): \(success)")
                })
            } else {
                let success = UIApplication.shared.openURL(url)
                print("Open \(url): \(success)")
            }
        }
    }
    
    func presentErrorAlert(){
        let errorAlert = UIAlertController(title: nil, message: NSLocalizedString("An unexpected error happened. Please try again.", comment: "Alert controller message presented when something wrong happen on user authentication"), preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Ok", comment: "Option from alert controller"), style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancel button pressed")
        })
        
        errorAlert.addAction(cancelAction)
        
        self.present(errorAlert, animated: true) {
            print("errorAlert presented")
        }
    }
    
    func oAuthDidFail(){
        NotificationCenter.default.removeObserver(self, name: .oAuthDidFail, object: nil)
        NotificationCenter.default.removeObserver(self, name: .tokenDidAuthorize, object: nil)
        
        presentErrorAlert()
    }
    
    func tokenDidAuthorize(notification:Notification) -> Void {
        NotificationCenter.default.removeObserver(self, name: .tokenDidAuthorize, object: nil)

        if(notification.object == nil){
            presentErrorAlert()
            return
        }
        
        let token = notification.object as! NSDictionary
        
    }
    
    @IBAction func refresh(_ sender: Any) {
        Authorization.sharedInstance.refreshToken()
    }

    
    
}

