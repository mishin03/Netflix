//
//  Protocols.swift
//  Netflix
//
//  Created by Илья Мишин on 06.12.2022.
//

import UIKit

protocol Movie {
    var title: String { get }
    var overview: String { get }
    var webview: URL { get }
}
