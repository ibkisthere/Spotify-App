//
//  AuthManager.swift
//  Spotify-App
//
//  Created by Ibukunoluwa Akintobi on 04/01/2024.
//

import Foundation


final class AuthManager {
    static let shared = AuthManager()
    
    private init() {}
    
    var isSignedIn:Bool {
        return false
    }
    
    
}
