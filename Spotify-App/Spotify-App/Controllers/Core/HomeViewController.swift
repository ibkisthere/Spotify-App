//
//  ViewController.swift
//  Spotify-App
//
//  Created by Ibukunoluwa Akintobi on 03/01/2024.
//

import UIKit

enum BrowseSectionType {
    case newReleases(viewModels:[NewReleasesCellViewModel]) // 1
    case featuredPlaylists(viewModels:[FeaturedPlaylistCellViewModel]) //2
    case recommendedTracks(viewModels:[RecommendedTrackCellViewModel]) //3
}

class HomeViewController: UIViewController {
    
    private var newAlbums:[Album] = []
    private var playlists:[Playlist] = []
    private var tracks : [AudioTrack] = []
    
    private var collectionView:UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout {
            sectionIndex, _ ->
            NSCollectionLayoutSection? in return
            HomeViewController.createSectionLayout(section: sectionIndex)
        }
    )
    
    private let spinner:UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = .white
        spinner.hidesWhenStopped = true
        return spinner
    }()
        
    private var sections = [BrowseSectionType]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .done, target: self, action: #selector(didTapSettings))
        configureCollectionView()
        view.addSubview(spinner)
        fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    private func configureCollectionView() {
        super.viewDidLayoutSubviews()
        view.addSubview(collectionView)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(NewReleaseCollectionViewCell.self, forCellWithReuseIdentifier: NewReleaseCollectionViewCell.identifier)
        collectionView.register(FeaturedPlaylistCollectionViewCell.self, forCellWithReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier)
        collectionView.register(RecommendedTrackCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier)
        collectionView.frame = view.bounds
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
    }
    
   //We need to wait for the api calls to be done before we set up our models with the viewModels , we will use a DispatchGroup so we can group together multiple concurrent operations
    
    private func fetchData(){
        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()
        print("start fetching data")
        var newReleases:NewReleasesResponse?
        var featuredPlaylist:FeaturedPlaylistsResponse?
        var recommendations:RecommendationsResponse?
        
        APICaller.shared.getnewReleases {
            // when we've left the scope of the block , we decrement the number of blocks we have left
            result in
            defer {
                group.leave()
            }
            switch result {
                case .success(let model) :
                    print("this is the new releases model \(model)")
                    newReleases = model
                case .failure(let error) :
                    print(error.localizedDescription)
            }
        }
        
        APICaller.shared.getFeaturedPlaylists {
            result in
            defer {
                group.leave()
            }
            switch result {
                case .success(let model) :
                    featuredPlaylist = model
                case .failure(let error) :
                    print(error.localizedDescription)
            }
        }
        //Recommended Tracks
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
                APICaller.shared.getRecommendations(genres:seeds) {
                    recommendedResult in
                    // we only want to leave this block when this second API call is done
                    defer {
                        group.leave()
                    }
                    switch recommendedResult {
                    case .success(let model) :
                        recommendations = model
                        break
                    case .failure(let error) :
                        print(error.localizedDescription)
                    }
                }
                case .failure(let error) :
                print(error.localizedDescription)
            }
        }
        
        //After we notify that we're done
        group.notify(queue:.main) {
            guard let newAlbums = newReleases?.albums.items,
                  let playlists = featuredPlaylist?.playlists.items,
                  let tracks = recommendations?.tracks else {
//                fatalError("Models are nil")
                return
            }
//            print("configuring viewModels")
            self.configureModels(
                newAlbums: newAlbums,
                playlists: playlists,
                tracks: tracks
            )
        }
    }
    
    private func configureModels(
        newAlbums:[Album],
        playlists:[Playlist],
        tracks:[AudioTrack]
    ) {
        self.newAlbums = newAlbums
        self.playlists = playlists
        self.tracks = tracks
        //Configure Models
        sections.append(.newReleases(viewModels: newAlbums.compactMap({
            return NewReleasesCellViewModel(
                name:$0.name,
                artworkURL:URL(string:$0.images.first?.url ?? ""),
                numberOfTracks: $0.total_tracks,
                artistName: $0.artists.first?.name ?? "-"
            )})
        ))
        sections.append(.featuredPlaylists(viewModels: playlists.compactMap({
            return FeaturedPlaylistCellViewModel(
                name:$0.name,
                artworkURL:URL(string:$0.images.first?.url ?? ""),
                creatorName: $0.owner.display_name
            )})
        ))
        sections.append(.recommendedTracks(viewModels: tracks.compactMap({
                return RecommendedTrackCellViewModel(
                    name: $0.name,
                    artistName: $0.artists.first?.name ?? "-",
                    artworkURL: URL(string:$0.album.images.first?.url ?? "")
                )}
        )))
        collectionView.reloadData()
    }
    
    @objc func didTapSettings(){
        let vc = SettingsViewController()
        vc.title = "Profile"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController:UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // section - is the index of the section
//        print(section)
        
        let type = sections[section]
        
        // get the number fo newReleases, featuredPlaylists and recommended tracks
              switch type {
              case .newReleases(let viewModels):
                  return viewModels.count
              case .featuredPlaylists(let viewModels):
                  return viewModels.count
              case .recommendedTracks(let viewModels):
                  return viewModels.count
             }
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) ->
    UICollectionViewCell {
        
        let type = sections[indexPath.section]
        
        
        switch type {
            case .newReleases(let viewModels):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: NewReleaseCollectionViewCell.identifier,
                    for: indexPath
                ) as? NewReleaseCollectionViewCell else {
                    return UICollectionViewCell()
                }
            let viewModel = viewModels[indexPath.row]
            cell.configure(with: viewModel)
                return cell
            
            case .featuredPlaylists(let viewModels):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier,
                    for: indexPath
                ) as? FeaturedPlaylistCollectionViewCell else {
                    return UICollectionViewCell()
                }
            let viewModel = viewModels[indexPath.row]
            cell.configure(with: viewModel)
            return cell
            
            case .recommendedTracks(let viewModels):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier:  RecommendedTrackCollectionViewCell.identifier,
                    for: indexPath
                ) as? RecommendedTrackCollectionViewCell else {
                    return UICollectionViewCell()
                }
            let viewModel = viewModels[indexPath.row]
            cell.configure(with: viewModel)
                return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let section = sections[indexPath.section]
        switch section {
        case .featuredPlaylists:
            break
        case .newReleases:
            // we want the nth element at that position
            let album = newAlbums[indexPath.row]
            let vc = AlbumViewController(album: album)
            vc.title = album.name
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
            break
        case .recommendedTracks:
            break
        }
    }
    
   static func createSectionLayout(section:Int) -> NSCollectionLayoutSection {
        switch section {
        case 0 :
            //you create an Item , you put the item into a group, the group enters a section and you return it
            
            //Item
            let item = NSCollectionLayoutItem(
                layoutSize:NSCollectionLayoutSize(
                    widthDimension:.fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
            ))
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            //Vertical Group
            // We want a vertical group inside of a horizontal group
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension:.fractionalWidth(1.0),
                    heightDimension: .absolute(130)),
                repeatingSubitem:item,
                count:3
            )
            
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension:.fractionalWidth(0.9),
                    heightDimension: .absolute(390)),
                repeatingSubitem:verticalGroup,
                count:1)
            
            //Section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .groupPaging
            return section
        case 1 :
            //you create an Item , you put the item into a group, the group enters a section and you return it
            
            //Item
            let item = NSCollectionLayoutItem(
                layoutSize:NSCollectionLayoutSize(
                    widthDimension:.absolute(200),
                    heightDimension: .absolute(200)
            ))
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension:.absolute(200),
                    heightDimension: .absolute(400)),
                repeatingSubitem:item,
                count:2
            )
            
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension:.absolute(200),
                    heightDimension: .absolute(400)),
                repeatingSubitem:verticalGroup,
                count:1)
            
            //Section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .continuous
            return section
        case 2 :
            //you create an Item , you put the item into a group, the group enters a section and you return it
            
            //Item
            let item = NSCollectionLayoutItem(
                layoutSize:NSCollectionLayoutSize(
                    widthDimension:.fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
            ))
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            //Vertical Group
            // We want a vertical group inside of a horizontal group
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension:.fractionalWidth(1.0),
                    heightDimension: .absolute(60)),
                repeatingSubitem:item,
                count:1
            )

            //Section
            let section = NSCollectionLayoutSection(group:group)
            return section
        default:   //you create an Item , you put the item into a group, the group enters a section and you return it
            
            //Item
            let item = NSCollectionLayoutItem(
                layoutSize:NSCollectionLayoutSize(
                    widthDimension:.fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
            ))
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            //Vertical Group
            // We want a vertical group inside of a horizontal group
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension:.fractionalWidth(1.0),
                    heightDimension: .absolute(130)),
                repeatingSubitem:item,
                count:3
            )
            
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension:.fractionalWidth(0.9),
                    heightDimension: .absolute(390)),
                repeatingSubitem:verticalGroup,
                count:1)
            
            //Section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .groupPaging
            return section
        }
    }
}

