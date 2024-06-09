//
//  PlayerViewController.swift
//  Spotify-App
//
//  Created by Ibukunoluwa Akintobi on 04/01/2024.
//

import UIKit


protocol PlayerViewControllerDelegate: AnyObject {
    func didTapPlayPause()
    func didTapForward()
    func didTapBackward()
    func didSlideSlider(_ value: Float)
}

class PlayerViewController: UIViewController {

    weak var dataSource: PlayerDataSource?
        weak var delegate: PlayerViewControllerDelegate?
        
        private let imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFill
            return imageView
        }()
    
        private let controlsView = PlayerControlsView()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .systemBackground
            view.addSubview(imageView)
            view.addSubview(controlsView)
            controlsView.translatesAutoresizingMaskIntoConstraints = false
            controlsView.delegate = self
            configureBarButtons()
            configure()
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                imageView.heightAnchor.constraint(equalTo:view.widthAnchor),
                
                controlsView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
                controlsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                controlsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
                controlsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5)
            ])

        }
        
        private func configure() {
            imageView.sd_setImage(with: dataSource?.imageURL, completed: nil)
            controlsView.configure(
                with: PlayerControlsViewViewModel(title: dataSource?.songName,
                subtitle: dataSource?.subtitle)
            )
        }
        
        private func configureBarButtons() {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapAction))
        }
        
        @objc private func didTapClose() {
            dismiss(animated: true, completion: nil)
        }
        
        @objc private func didTapAction() {
            // Actions
        }
        
        func refreshUI() {
            configure()
        }
    }

    extension PlayerViewController: PlayerControlsViewDelegate {
        func playerControlsView(_ playerControlsView: PlayerControlsView, didSlideSlider value: Float) {
            delegate?.didSlideSlider(value)
        }
        
        func playerControlsViewDiDTapPlayPause(_ playerControlsView: PlayerControlsView) {
            delegate?.didTapPlayPause()
        }
        
        func playerControlsViewDiDTapForwardButton(_ playerControlsView: PlayerControlsView) {
            delegate?.didTapForward()
        }
        
        func playerControlsViewDiDTapBackwardsButton(_ playerControlsView: PlayerControlsView) {
            delegate?.didTapBackward()
        }
}
