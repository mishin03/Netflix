//
//  YouTubeSearchResponse.swift
//  Netflix
//
//  Created by Илья Мишин on 23.11.2022.
//

import UIKit

struct YouTubeSearchResponse: Codable {
    let items: [VideoElements]
}

struct VideoElements: Codable {
    let id: IDVideoElement
}

struct IDVideoElement: Codable {
    let kind: String
    let videoId: String
}
