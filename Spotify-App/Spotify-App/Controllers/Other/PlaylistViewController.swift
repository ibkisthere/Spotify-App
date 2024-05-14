//
//  PlaylistViewController.swift
//  Spotify-App
//
//  Created by Ibukunoluwa Akintobi on 04/01/2024.
//

import UIKit

class PlaylistViewController: UIViewController {

    private let playlist : Album
    
    init(playlist: Album) {
        self.playlist = playlist
        super.init()
    }
    required init(coder:NSCoder) {
        fatalError()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = playlist.name
        view.backgroundColor = .systemBackground
    }
}
