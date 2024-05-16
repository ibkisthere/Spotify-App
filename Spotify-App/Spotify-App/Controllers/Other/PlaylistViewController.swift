//
//  PlaylistViewController.swift
//  Spotify-App
//
//  Created by Ibukunoluwa Akintobi on 04/01/2024.
//

import UIKit

class PlaylistViewController: UIViewController {

    private let playlist :Playlist
    
    init(playlist:Playlist) {
        self.playlist = playlist
        super.init(nibName:nil, bundle:nil)
    }
    required init(coder:NSCoder) {
        fatalError()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = playlist.name
        view.backgroundColor = .systemBackground
        
        APICaller.shared.getPlaylistDetails(for: playlist) {
            result in
            switch result {
            case .success(let model):
                print("this is the playlists model here \(model)")
                break
            case .failure(let error):
                break
            }
        }
    }
}
