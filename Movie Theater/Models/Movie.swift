//
//  Movie.swift
//  Movie Theater
//
//  Created by Federico Vitale on 28/11/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import Foundation

struct Movie: Hashable, Codable {
    let id: Int
    let title: String
    let description: String
    let backdrop: String?
    let poster: String
    let voteAverage: Double
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case backdrop = "backdrop_path"
        case poster = "poster_path"
        case voteAverage = "vote_average"
        case description = "overview"
    }
}
