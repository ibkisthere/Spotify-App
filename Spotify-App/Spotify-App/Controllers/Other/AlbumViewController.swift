//
//  AlbumViewController.swift
//  Spotify-App
//
//  Created by Ibukunoluwa Akintobi on 13/05/2024.
//

import UIKit

class AlbumViewController: UIViewController {
    
    private let album : Album
    
    init(album: Album) {
        self.album = album
        super.init(nibName:nil, bundle:nil)
    }
    required init(coder:NSCoder) {
        fatalError()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = album.name
        view.backgroundColor = .systemBackground
    }
}
