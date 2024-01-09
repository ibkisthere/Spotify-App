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
        static let clientID = "f779bdcfc1d54de588a2eb716d01fd24"
        static let clientSecret = "43b38ec21dde4f74b9b900acea420de2"
    }
    
    private init() {}
    
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
}
