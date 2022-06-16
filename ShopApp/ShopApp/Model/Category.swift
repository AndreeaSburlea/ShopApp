//
//  Category.swift
//  ShopApp
//
//  Created by Andreea Sburlea on 15.06.2022.
//

import Foundation
import UIKit

struct Category: Hashable {
    private var name: String
    private var image: UIImage

    func getName() -> String { return self.name }
    func getImage() -> UIImage { return self.image}

    mutating func setName(name: String) { self.name = name }
    mutating func setImage(image: UIImage) { self.image = image }

    init (name: String, image: UIImage) {
        self.name = name
        self.image = image
    }

    mutating func configure(name: String, image: UIImage) {
        self.name = name
        self.image = image
    }

    init() {
        self.init(name: "", image: UIImage())
    }
}
