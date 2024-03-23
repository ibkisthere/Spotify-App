//
//  AuthResponse.swift
//  Spotify-App
//
//  Created by Ibukunoluwa Akintobi on 17/01/2024.
//

import Foundation


struct AuthResponse : Codable {
    let access_token:String
    let expires_in:Int
    let refresh_token:String?
    let token_type:String
}
