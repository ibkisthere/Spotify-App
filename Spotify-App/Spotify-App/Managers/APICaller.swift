//
//  APICaller.swift
//  Spotify-App
//
//  Created by Ibukunoluwa Akintobi on 04/01/2024.
//

import Foundation


final class APICaller {
    static let shared = APICaller()
    
    private init() {}
    
    struct Constants {
        static let baseAPIURL = "https://api.spotify.com/v1"
    }
    
    enum APIError:Error {
        case failedToGetData
    }
    
    public func getAlbumDetails(for album: Album, completion: @escaping (Result<AlbumDetailsResponse, Error>) -> Void) {
            performRequest(
                url: URL(string: Constants.baseAPIURL + "/albums/" + album.id),
                type: .GET,
                responseType: AlbumDetailsResponse.self,
                completion: completion
            )
    }
        
    public func getPlaylistDetails(for playlist: Playlist, completion: @escaping (Result<PlaylistDetailsResponse, Error>) -> Void) {
            performRequest(
                url: URL(string:Constants.baseAPIURL + "/playlists/" + playlist.id),
                type: .GET,
                responseType: PlaylistDetailsResponse.self,
                completion: completion
        )
    }
        
    public func getCurrentUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
            performRequest(
                url: URL(string:Constants.baseAPIURL + "/me"),
                type: .GET,
                responseType: UserProfile.self,
                completion: completion
            )
    }
        
    public func getNewReleases(completion: @escaping (Result<NewReleasesResponse, Error>) -> Void) {
            performRequest(
                url: URL(string:Constants.baseAPIURL + "/browse/new-releases?limit=50"),
                type: .GET,
                responseType: NewReleasesResponse.self,
                completion: completion
            )
    }
        
    public func getFeaturedPlaylists(completion: @escaping (Result<FeaturedPlaylistsResponse, Error>) -> Void) {
            performRequest(
                url: URL(string:Constants.baseAPIURL + "/browse/featured-playlists?limit=2"),
                type: .GET,
                responseType: FeaturedPlaylistsResponse.self,
                completion: completion
            )
    }
        
    public func getRecommendations(genres: Set<String>, completion: @escaping (Result<RecommendationsResponse, Error>) -> Void) {
            let seeds = genres.joined(separator: ",")
            performRequest(
                url: URL(string:Constants.baseAPIURL + "/recommendations?limit=20&seed_genres=\(seeds)"),
                type: .GET,
                responseType: RecommendationsResponse.self,
                completion: completion
            )
    }
        
    public func getRecommendedGenres(completion: @escaping (Result<RecommendedGenresResponse, Error>) -> Void) {
            performRequest(
                url: URL(string: Constants.baseAPIURL + "/recommendations/available-genre-seeds"),
                type: .GET,
                responseType: RecommendedGenresResponse.self,
                completion: completion
            )
    }
    
    public func getShows(completion: @escaping (Result<RecommendedGenresResponse, Error>) -> Void) {
            performRequest(
                url: URL(string: Constants.baseAPIURL + "/me/shows?offset=0&limit=20"),
                type: .GET,
                responseType: RecommendedGenresResponse.self,
                completion: completion
            )
    }
    
    
    public func getCategories(completion: @escaping (Result<[Category], Error>) -> Void) {
        createRequest(
            with: URL(string: Constants.baseAPIURL + "/browse/categories?limit=50"),
            type: .GET
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(AllCategoriesResponse.self,
                                                        from: data)
                    completion(.success(result.categories.items))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getCategoryPlaylists(category: Category, completion: @escaping (Result<[Playlist], Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/browse/categories/\(category.id)/playlists?limit=50"),
                      type: .GET
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(CategoryPlaylistsResponse.self,
                                                        from: data)
                    let playlists = result.playlists.items
                    completion(.success(playlists))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: - Search
    
    public func search(with query: String, completion: @escaping (Result<[SearchResult], Error>) -> Void) {
        createRequest(
            with: URL(string: Constants.baseAPIURL+"/search?limit=10&type=album,artist,playlist,track&q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"),
            type: .GET
        ) { request in
            print(request.url?.absoluteString ?? "none")
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(SearchResultsResponse.self, from: data)
                    var searchResults: [SearchResult] = []
                    searchResults.append(contentsOf: result.tracks.items.compactMap({ .track(model: $0)}))
                    searchResults.append(contentsOf: result.albums.items.compactMap({ .album(model: $0)}))
                    searchResults.append(contentsOf: result.artists.items.compactMap({ .artist(model: $0)}))
                    searchResults.append(contentsOf: result.playlists.items.compactMap({ .playlist(model: $0)}))
                    
                    completion(.success(searchResults))
                }
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    
    
    enum HTTPMethod : String {
        case GET
        case POST
    }
    
    
    // create a generic request that every API call will be building on top off
    private func createRequest(
        with url: URL?,
        type:HTTPMethod,
        completion: @escaping (URLRequest) -> Void
    ) {
        AuthManager.shared.withValidToken { token in
            guard let apiURL = url else {
                return
            }
            var request = URLRequest(url: apiURL)
            request.setValue("Bearer \(token)", forHTTPHeaderField:"Authorization")
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30
            completion(request)
        }
    }
    
    private func performRequest<T:Decodable>(
        url: URL?,
        type: HTTPMethod,
        responseType: T.Type,
        completion: @escaping (Result<T,Error>)-> Void) {
            createRequest(with: url, type:type) {
            request in
            let task = URLSession.shared.dataTask(with: request){
                data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(responseType,from: data)
                      completion(.success(result))
                }
                catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
}
