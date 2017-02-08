//
//  ViewController.swift
//  a-simple-reddit-client
//
//  Created by Rodrigo Bueno Tomiosso on 07/02/17.
//  Copyright © 2017 mourodrigo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let clientId = "isBHEDq__wuqTQ"
    let responseType = "code"
    let state = "r239847y52f34v8347y"
    let duration = "permanent"
    let scope = "read"
    let redirect_uri = "mourodrigo.a-simple-reddit-client://callback"

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
        
        let authUrl = "https://www.reddit.com/api/v1/authorize.compact?client_id=\(clientId)&response_type=\(responseType)&state=\(state)&redirect_uri=\(redirect_uri)&duration=\(duration)&scope=\(scope)"
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.oAuthDidReturn(notification:)), name: .oAuthDidReturn, object: nil) //observer will be called on authentication callback
        
        self.openOnBrowser(url: authUrl)
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
        
        if(notification.object == nil){
            presentErrorAlert()
            return
        }
        
        let authQueryString = notification.object as! String
        
        let authParams = authQueryString.componentsFromQueryString
        
        if( authParams.count==0 || !authQueryString.contains(state) ){
            presentErrorAlert()
            return
        }
        
        let code = authParams["code"]! as String
        
        accessToken(with: code)
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
    
    func accessToken(with code:String){
        
        let url = URL(string: "https://www.reddit.com/api/v1/access_token")!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let username = clientId
        let password = ""
        let loginString = String(format: "%@:%@", username, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let paramString = "grant_type=authorization_code&code=\(code)&redirect_uri=\(self.redirect_uri)"
        
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        
        let task = session.dataTask(with: request) { ( data, response, error) in
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print(dataString)
        }
  
        task.resume()
        
    }
    
}

