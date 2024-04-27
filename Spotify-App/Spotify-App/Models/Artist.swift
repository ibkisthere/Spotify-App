//
//  Artist.swift
//  Spotify-App
//
//  Created by Ibukunoluwa Akintobi on 04/01/2024.
//

import Foundation


struct Artist : Codable {
    let id : String
    let name: String
    let type:String
    let external_urls : [String:String]
}
