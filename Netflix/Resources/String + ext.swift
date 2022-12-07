//
//  String + ext.swift
//  Netflix
//
//  Created by Илья Мишин on 22.11.2022.
//

import UIKit

extension String {
    func capitalizedFirstLetter() -> String {
        return self.prefix(1).uppercased() + self.lowercased().dropFirst()
    }
}
