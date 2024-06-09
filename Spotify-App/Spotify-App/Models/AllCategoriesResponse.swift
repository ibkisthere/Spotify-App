//
//  AllCategoriesResponse.swift
//  Spotify-App
//
//  Created by Ibukunoluwa Akintobi on 07/06/2024.
//

import Foundation

struct AllCategoriesResponse: Codable {
    let categories: Categories
}

struct Categories: Codable {
    let items: [Category]
}
struct Category: Codable {
    let id: String
    let name: String
    let icons: [APIimage]
}


