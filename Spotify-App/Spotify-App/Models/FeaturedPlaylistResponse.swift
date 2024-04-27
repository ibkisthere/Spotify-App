//
//  FeaturedPlaylistResponse.swift
//  Spotify-App
//
//  Created by Ibukunoluwa Akintobi on 25/04/2024.
//

import Foundation

struct FeaturedPlaylistsResponse:Codable {
    let playlists:[PlaylistResponse]
}

struct PlaylistResponse : Codable {
    let items : [Playlist]
}

struct Playlist : Codable {
    let description: String
    let external_urls:[String:String]
    let id:String
    let images:[APIimage]
    let name:String
    let owner:User
}

struct User :Codable {
    let display_name:String
    let external_urls:[String:String]
    let id : String
}
