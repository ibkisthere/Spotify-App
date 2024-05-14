//
//  Playlist.swift
//  Spotify-App
//
//  Created by Ibukunoluwa Akintobi on 04/01/2024.
//

import Foundation

struct Playlist : Codable {
    let description: String
    let external_urls:[String:String]
    let id:String
    let images:[APIimage]
    let name:String
    let owner:User
}

