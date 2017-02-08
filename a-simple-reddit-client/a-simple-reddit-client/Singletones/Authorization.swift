//
//  Authorization.swift
//  a-simple-reddit-client
//
//  Created by Rodrigo Bueno Tomiosso on 08/02/17.
//  Copyright © 2017 mourodrigo. All rights reserved.
//

import Foundation


class Authorization {
    
    let clientId = "isBHEDq__wuqTQ"
    let responseType = "code"
    let state = "r239847y52f34v8347y"
    let duration = "permanent"
    let scope = "read"
    let redirect_uri = "mourodrigo.a-simple-reddit-client://callback"

    var token = NSDictionary()
    
    static let sharedInstance: Authorization = {
        let instance = Authorization()
        return instance
    }()
    
    private init(){
        print("Authorization init")
    }
    
    func authURL() -> String{
        return "https://www.reddit.com/api/v1/authorize.compact?client_id=\(clientId)&response_type=\(responseType)&state=\(state)&redirect_uri=\(redirect_uri)&duration=\(duration)&scope=\(scope)"
    }
    
    func prepareForAuthorize(){
        NotificationCenter.default.removeObserver(self, name: .oAuthDidReturn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.oAuthDidReturn(notification:)), name: .oAuthDidReturn, object: nil) //observer will be called on authentication callback
    }
    
    @objc func oAuthDidReturn(notification:Notification) -> Void {
        NotificationCenter.default.removeObserver(self, name: .oAuthDidReturn, object: nil)
        
        if(notification.object == nil){
            NotificationCenter.default.post(name:.oAuthDidFail, object: nil, userInfo: nil)
            return
        }
        
        let authQueryString = notification.object as! String
        
        let authParams = authQueryString.componentsFromQueryString
        
        if( authParams.count==0 || !authQueryString.contains(state) ){
            NotificationCenter.default.post(name:.oAuthDidFail, object: nil, userInfo: nil)
            return
        }
        
        let code = authParams["code"]! as String
        
        accessToken(with: code)
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

            do {
            
                let JSONReturn = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : AnyObject]

                print("tokenDidAuthorize \(JSONReturn)")
                
                self.token = NSDictionary.init(dictionary: JSONReturn)
                
                NotificationCenter.default.post(name:.tokenDidAuthorize, object: JSONReturn, userInfo: nil)

            }
            catch {
                NotificationCenter.default.post(name:.oAuthDidFail, object: nil, userInfo: nil)
            }
        }
        
        task.resume()
        
    }  
}
