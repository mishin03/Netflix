//
//  Movie.swift
//  Netflix
//
//  Created by Илья Мишин on 22.11.2022.
//

import UIKit

struct TitleResponse: Codable {
    let results: [TitleMovie]
}

struct TitleMovie: Codable {
    let id: Int
    let media_type: String?
    let original_name: String?
    let original_title: String?
    let poster_path: String?
    let overview: String?
    let vote_count: Int
    let release_date: String?
    let vote_average: Double
}
