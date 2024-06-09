//
//  SearchResult.swift
//  Spotify-App
//
//  Created by Ibukunoluwa Akintobi on 07/06/2024.
//

import Foundation

enum SearchResult {
    case artist(model: Artist)
    case album(model: Album)
    case track(model: AudioTrack)
    case playlist(model: Playlist)
}
