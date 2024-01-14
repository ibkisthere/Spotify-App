//
//  AuthManager.swift
//  Spotify-App
//
//  Created by Ibukunoluwa Akintobi on 04/01/2024.
//

import Foundation


final class AuthManager {
    static let shared = AuthManager()
    
    struct Constants {
        static let clientID = "6a7e06071f03419c8c4d582b759f469e"
        /// ideally we would put the client secret in our backend 
        static let clientSecret = "956e7a857e8045f6980ad552d33d2c68"
        static let tokenAPIURL = "https://accounts.spotify.com/api/token"
    }
    
    private init() {}
    public var signInUrl:URL? {
        let scopes = "user-read-private"
        let redirectURI = "https://www.github.com/thisisibukunoluwa/"
        let base = "https://accounts.spotify.com/authorize"
        let string = "\(base)?response_type=code&client_id=\(Constants.clientID)&scope=\(scopes)&redirect_uri=\(redirectURI)&show_dialog=TRUE"
        return URL(string: string)
    }
    
    var isSignedIn:Bool {
        return false
    }
    
    private var accessToken :String? {
        return nil
    }
    private var refreshToken :String? {
        return nil
    }
    private var tokenExpirationDate :String? {
        return nil
    }
    private var shouldRefreshToken :String? {
        return nil
    }
    public func exchangeCodeForToken(code:String, completion: @escaping (Bool)-> Void){
        // we are going to make an api call to get token
        guard let url = URL(string:Constants.tokenAPIURL) else {
            return
        }
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: "authorization_code"),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = components.query?.data(using: .utf8)
        request.setValue("Basic", forHTTPHeaderField: "Authorizaztion")
        
        let basicToken = Constants.clientID + ":" + Constants.clientSecret
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else {
            print("Failure to get base64")
            completion(false)
            return
        }
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data,_,error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                print("SUCCESS:\(json)")
            }
            catch {
                print(error.localizedDescription)
                completion(false)
            }
        }
        task.resume()
    }
    public func cacheToken(){
        
    }
    
}
