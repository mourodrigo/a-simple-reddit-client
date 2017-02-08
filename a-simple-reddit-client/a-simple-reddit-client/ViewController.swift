//
//  ViewController.swift
//  a-simple-reddit-client
//
//  Created by Rodrigo Bueno Tomiosso on 07/02/17.
//  Copyright © 2017 mourodrigo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let securityAuthRandomString = "r239847y52f34v8347y"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didPressLoginButton(_ sender: AnyObject) {

        let clientId = "isBHEDq__wuqTQ"
        let responseType = "code"
        let state = securityAuthRandomString
        let redirect_uri = "mourodrigo.a-simple-reddit-client://callback" //can get it directly from info plist if necessary
        let duration = "permanent"
        let scope = "read"
        
        let authUrl = "https://www.reddit.com/api/v1/authorize.compact?client_id=\(clientId)&response_type=\(responseType)&state=\(state)&redirect_uri=\(redirect_uri)&duration=\(duration)&scope=\(scope)"
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.oAuthDidReturn(notification:)), name: .oAuthDidReturn, object: nil) //observer will be called on authentication callback
        
        openOnBrowser(url: authUrl)
    }
    
    func openOnBrowser(url: String) {
        if let url = URL(string: url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:],
                                          completionHandler: {
                                            (success) in
                                            print("Open \(url): \(success)")
                })
            } else {
                let success = UIApplication.shared.openURL(url)
                print("Open \(url): \(success)")
            }
        }
    }
    
    
    func oAuthDidReturn(notification:Notification) -> Void {
        NotificationCenter.default.removeObserver(self, name: .oAuthDidReturn, object: nil)
        
        print(notification.object)
        
        if(notification.object == nil){
            presentErrorAlert()
            return
        }
        
        let authQueryString = notification.object as! String
        
        let authParams = authQueryString.components(separatedBy: "&")
        
        if(authParams.count==0 || !authQueryString.contains(self.securityAuthRandomString)){
            presentErrorAlert()
            return
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
    
    
}

