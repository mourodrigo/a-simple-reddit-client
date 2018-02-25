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

    var token = NSMutableDictionary()
    
    static let sharedInstance: Authorization = {
        let instance = Authorization()
        return instance
    }()
    
    private init() {
        print("Authorization init")
    }
    
    func authURL() -> String {
        return "https://www.reddit.com/api/v1/authorize.compact?client_id=\(clientId)&response_type=\(responseType)&state=\(state)&redirect_uri=\(redirect_uri)&duration=\(duration)&scope=\(scope)"
    }
    
    func prepareForAuthorize() {
        NotificationCenter.default.removeObserver(self, name: .oAuthDidReturn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.oAuthDidReturn(notification:)), name: .oAuthDidReturn, object: nil) //observer will be called on authentication callback
    }
    
    @objc func oAuthDidReturn(notification:Notification) -> Void {
        NotificationCenter.default.removeObserver(self, name: .oAuthDidReturn, object: nil)
        
        guard let authQueryString = notification.object as? String else {
            NotificationCenter.default.post(name:.oAuthDidFail, object: nil, userInfo: nil)
            return
        }
        
        let authParams = authQueryString.componentsFromQueryString
        
        if authParams.count == 0 || !authQueryString.contains(state) {
            NotificationCenter.default.post(name:.oAuthDidFail, object: nil, userInfo: nil)
            return
        }
        
        let code = authParams["code"]! as String
        
        getToken(with: "grant_type=authorization_code&code=\(code)&redirect_uri=\(self.redirect_uri)")
    }
    
    func getToken(with params:String) {
        
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
        
        request.httpBody = params.data(using: String.Encoding.utf8)
        
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        let requestDate = Date()

        let task = session.dataTask(with: request) { ( data, response, error) in

            do {
            
                let JSONReturn = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : AnyObject]

                print("tokenDidAuthorize \(JSONReturn)")
                
                if self.token.allKeys.count == 0 { // this is for the first access token request

                    self.token = NSMutableDictionary.init(dictionary: JSONReturn)
                    
                    //save all to user default so we done have to call for login when user returns to the app
                    UserDefaults.standard.setValue(self.token.value(forKey: "access_token"), forKey: "access_token")
                    UserDefaults.standard.setValue(self.token.value(forKey: "expires_in"), forKey: "expires_in")
                    UserDefaults.standard.setValue(self.token.value(forKey: "scope"), forKey: "scope")
                    UserDefaults.standard.setValue(self.token.value(forKey: "token_type"), forKey: "token_type")
                    UserDefaults.standard.setValue(self.token.value(forKey: "refresh_token"), forKey: "refresh_token")
                  
                    
                } else { // and this is for token refresh, so just update the access_token
                    
                    let JSONDictionary = NSMutableDictionary.init(dictionary: JSONReturn)
                    self.token.setValue(JSONDictionary.value(forKey: "access_token"), forKey: "access_token")
                    UserDefaults.standard.setValue(self.token.value(forKey: "access_token"), forKey: "access_token")
                
                }
                
                if let expiresIn = self.token["expires_in"] as? Int {
                    let validThrough = requestDate.addingTimeInterval(TimeInterval.init(expiresIn))
                    self.token.setValue(validThrough, forKey: "valid_through") //using a Date to token validation keep it more simple
                    UserDefaults.standard.setValue(self.token.value(forKey: "valid_through"), forKey: "valid_through")
                }
                
                NotificationCenter.default.post(name:.tokenDidAuthorize, object: JSONReturn, userInfo: nil)

            } catch {
                NotificationCenter.default.post(name:.oAuthDidFail, object: nil, userInfo: nil)
            }
        }
        task.resume()
    }
    
    func refreshToken() {
        if let refreshToken = self.token["refresh_token"] as? String {
            getToken(with: "grant_type=refresh_token&refresh_token=\(refreshToken)")
        }
    }

    func restoreFromUserDefault(key:String) {
        self.token.setValue(UserDefaults.standard.value(forKey: key), forKey: key)
    }
    
    func authorize() {
     
        prepareForAuthorize()
        
        if UserDefaults.standard.value(forKey: "access_token") != nil {
            restoreFromUserDefault(key: "access_token")
            restoreFromUserDefault(key: "expires_in")
            restoreFromUserDefault(key: "refresh_token")
            restoreFromUserDefault(key: "scope")
            restoreFromUserDefault(key: "token_type")
            restoreFromUserDefault(key: "valid_through")
        }
        
        //checks for token existance and expiration date
        
        if self.token.allKeys.count == 0 { // // if user have to authorize with user/password

            NotificationCenter.default.post(name:.oAuthNeedsUserLogin, object: nil, userInfo: nil)
            
        } else if let validThrough = self.token["valid_through"] as? Date, validThrough.isPassed() { // has a token, just have to refresh it

            refreshToken()

        } else if let validThrough = self.token["valid_through"] as? Date, !validThrough.isPassed() { // has a valid token

            NotificationCenter.default.post(name:.tokenDidAuthorize, object: self.token, userInfo: nil)

        }
    }
}
