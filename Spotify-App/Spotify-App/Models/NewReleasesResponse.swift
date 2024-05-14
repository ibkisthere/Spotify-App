//
//  NewReleasesResponse.swift
//  Spotify-App
//
//  Created by Ibukunoluwa Akintobi on 23/04/2024.
//

import Foundation

struct NewReleasesResponse : Codable {
    let albums: AlbumsResponse
}

struct AlbumsResponse: Codable {
    let items:[Album]
}

struct Album : Codable {
    let album_type:String
    let available_markets:[String]
    let id:String
    let images : [APIimage]
    let release_date: String
    let total_tracks: Int
    let artists:[Artist]
    let name:String
}
