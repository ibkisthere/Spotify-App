//
//  UserProfile.swift
//  Spotify-App
//
//  Created by Ibukunoluwa Akintobi on 04/01/2024.
//

import Foundation


struct UserProfile:Codable {
    let country : String
    let display_name: String
    let email:String
    let explicit_content:[String:Int]
    let external_urls:[String:String]
//    let followers : [String:Codable?]
    let id:String
    let product:String
}

struct UserImage:Codable {
    let url :String
}
