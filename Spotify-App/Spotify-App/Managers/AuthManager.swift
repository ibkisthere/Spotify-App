//
//  AuthManager.swift
//  Spotify-App
//
//  Created by Ibukunoluwa Akintobi on 04/01/2024.
//

import Foundation


final class AuthManager {
    static let shared = AuthManager()
    
    private var refreshingToken = false
    
    struct Constants {
        static let clientID = "6a7e06071f03419c8c4d582b759f469e"
        /// ideally we would put the client secret in our backend 
        static let clientSecret = "956e7a857e8045f6980ad552d33d2c68"
        static let tokenAPIURL = "https://accounts.spotify.com/api/token"
        static let redirectURI = "https://www.github.com/thisisibukunoluwa/"
        static let scopes = "user-read-private%20playlist-modify-public%20playlist-read-private%20user-follow-read%20user-library-modify%20user-library-read%20user-read-email"
    }
    
    private init() {}
    
    public var signInUrl:URL? {
        let base = "https://accounts.spotify.com/authorize"
        let string = "\(base)?response_type=code&client_id=\(Constants.clientID)&scope=\(Constants.scopes)&redirect_uri=\(Constants.redirectURI)&show_dialog=TRUE"
        return URL(string: string)
    }
    
    var isSignedIn: Bool {
        return accessToken != nil
    }
    
    private var accessToken :String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }
    private var refreshToken :String? {
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    private var tokenExpirationDate :Date? {
        return UserDefaults.standard.object(forKey: "expiration_date") as? Date
    }
    private var shouldRefreshToken :Bool {
        //should refresh token is giving me false even with this condition, so it does and early return
        // when i print the expirationdate it gives me nil
//        print("this is the expiration date \(String(describing: tokenExpirationDate))")
        guard let expirationDate = tokenExpirationDate else {
            return false
        }
       // the date is giving me my local date one hour behind, i'll add one hour to it as a temporary fix
        //- it works
        let currentDate = Date().addingTimeInterval(3600)
        let fiveMinutes: TimeInterval = 300
//
//        print("this is the current date \(String(describing:currentDate))")
//        print("this is the  date \(String(describing: currentDate.addingTimeInterval(fiveMinutes)))")
//        print("this is the expiration date \(String(describing: tokenExpirationDate))")
//
        return currentDate.addingTimeInterval(fiveMinutes) >= expirationDate
    }
    
    public func exchangeCodeForToken(code:String, completion: @escaping ((Bool)-> Void)) {
        // we are going to make an api call to get token
        guard let url = URL(string:Constants.tokenAPIURL) else {
            return
        }
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)
        
        
        let basicToken = Constants.clientID + ":" + Constants.clientSecret
        let data = basicToken.data(using: .utf8)
        
        guard let base64String = data?.base64EncodedString() else {
            print("Failure to get base64")
            completion(false)
            return
        }
        
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data,_,error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
//                print("hello i am the result, i am here \(result.access_token) \(result.expires_in) \(result.token_type) \(result.refresh_token)")
                self?.cacheToken(result:result)
                completion(true)
            }
            catch {
                print("this is the error localized description:\(error.localizedDescription)")
                completion(false)
            }
        }
        task.resume()
    }
    
    /// An array of escaping closures
    private var onRefreshBlocks = [((String) -> Void)]()
    
    /// Supplies valid token to be used with API calls 
    public func withValidToken(completion: @escaping (String) -> Void) {
        guard !refreshingToken else {
            onRefreshBlocks.append(completion)
            return
        }
        if shouldRefreshToken {
            // Refresh
            // print("yes i refreshed")
            refreshIfNeeded { [weak self] success in
                    if let token = self?.accessToken, success {
                        completion(token)
                }
            }
        } else if let token = accessToken {
            completion(token)
        }
    }
    
    
    public func refreshIfNeeded(completion:((Bool) -> Void)?) {
        guard !refreshingToken else {
            return
        }
        
        guard shouldRefreshToken else {
            completion?(true)
            return
        }
        
        guard let refreshToken = self.refreshToken else {
            return
        }
        
        guard let url = URL(string:Constants.tokenAPIURL) else {
            return
        }
        
        refreshingToken = true
        
//        print("i am refreshing here in the refreshIfNeeded")
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken),
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)
        
        
        let basicToken = Constants.clientID + ":" + Constants.clientSecret
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else {
            print("Failure to get base64")
            completion?(false)
            return
        }
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data,_,error in
            self?.refreshingToken = false
            guard let data = data, error == nil else {
                completion?(false)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.onRefreshBlocks.forEach {
                    $0(result.access_token)
                }
                self?.onRefreshBlocks.removeAll()
                self?.cacheToken(result:result) 
//                print("SUCCESS:\(result)")
                completion?(true)
            }
            catch {
                completion?(false)
            }
        }
        task.resume()
    }
    
    
    
    public func cacheToken(result:AuthResponse) {
        UserDefaults.standard.setValue(result.access_token, forKey: "access_token")
        if let refresh_token = result.refresh_token {
            UserDefaults.standard.setValue(result.refresh_token, forKey: "refresh_token")
        }
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)), forKey: "expiration_date")
    }
     
}
