//
//  ViewController.swift
//  Spotify-App
//
//  Created by Ibukunoluwa Akintobi on 03/01/2024.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .done, target: self, action: #selector(didTapSettings))
        fetchData()
    }
    
    private func fetchData(){
        APICaller.shared.getRecommendedGenres {
            result in
            switch result {
                case .success(let model) :
                let genres = model.genres
                var seeds = Set<String>()
                while seeds.count < 5 {
                    if let random = genres.randomElement() {
                        seeds.insert(random)
                    }
                }
                print(seeds)
                APICaller.shared.getRecommendations(genres:seeds) {
                    _ in 
                }
                case .failure(let error) :
                break
            }
        }
    }
    
    
    @objc func didTapSettings(){
        let vc = SettingsViewController()
        vc.title = "Profile"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}

