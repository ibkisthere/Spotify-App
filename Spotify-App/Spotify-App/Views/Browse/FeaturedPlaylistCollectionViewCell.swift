//
//  FeaturedPlaylistCollectionViewCell.swift
//  Spotify-App
//
//  Created by Ibukunoluwa Akintobi on 03/05/2024.
//

import UIKit
import SDWebImage

class FeaturedPlaylistCollectionViewCell: UICollectionViewCell {
    static let identifier = "FeaturedPlaylistCollectionViewCell"
    
    private let playlistCoverImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 4
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let playlistNameLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .regular)
        label.textAlignment = .center
        return label
    }()
    
    private let creatorNameLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize:20, weight: .light)
        return label
    }()
    
    override init(frame:CGRect) {
        super.init(frame: frame)
//        contentView.backgroundColor = .red
        contentView.addSubview(playlistCoverImageView)
        contentView.addSubview(playlistNameLabel)
        contentView.addSubview(creatorNameLabel)
        contentView.clipsToBounds = true
    }
    
    required init?(coder:NSCoder) {
        fatalError()
    }
    // Change all these fixed sizes to use autolayout
    override func layoutSubviews() {
        super.layoutSubviews()
        creatorNameLabel.frame = CGRect(x: 3,
                                        y: contentView.height - 44,
                                        width: contentView.width - 6,
                                        height: 30
        )
        
        playlistNameLabel.frame = CGRect(x: 3,
                                        y: contentView.height - 90,
                                        width: contentView.width - 6,
                                        height: 30
        )
        
        let imageSize = contentView.height - 90
        
        playlistCoverImageView.frame = CGRect(
            x: (contentView.width - imageSize) / 2,
            y: 3,
            width: imageSize,
            height: imageSize
        )
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playlistNameLabel.text = nil
        playlistCoverImageView.image = nil
        creatorNameLabel.text = nil
    }
    
    func configure(with viewModel:FeaturedPlaylistCellViewModel) {
        playlistNameLabel.text = viewModel.name
        playlistCoverImageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
        creatorNameLabel.text = viewModel.creatorName
    }
}
