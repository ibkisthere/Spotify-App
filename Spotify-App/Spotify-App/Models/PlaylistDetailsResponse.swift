//
//  PlaylistDetailsResponse.swift
//  Spotify-App
//
//  Created by Ibukunoluwa Akintobi on 16/05/2024.
//

import Foundation

struct PlaylistDetailsResponse:Codable {
    let description:String
    let external_urls:[String:String]
    let id :String
    let images:[APIimage]
    let name: String
    let tracks: PlaylistTracksResponse
}

struct PlaylistTracksResponse: Codable {
    let items: [PlaylistItem]
}

struct PlaylistItem : Codable {
    let track:AudioTrack
}
