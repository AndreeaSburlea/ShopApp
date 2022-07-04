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
    private var type: [String: Bool]

    func getName() -> String { self.name }
    func getImage() -> UIImage { self.image }
    func getType() -> [String: Bool] { self.type }

    mutating func setName(name: String) { self.name = name }
    mutating func setImage(image: UIImage) { self.image = image }
    mutating func setType(type: [String: Bool]) { self.type = type}

    init (name: String, image: UIImage, type: [String: Bool]) {
        self.name = name
        self.image = image
        self.type = type
    }

    mutating func configure(name: String, image: UIImage, type: [String: Bool]) {
        self.name = name
        self.image = image
        self.type = type
    }

    init() {
        self.init(name: "", image: UIImage(), type: [:])
    }

    func isMale() -> Bool { return type["male"]! }

    func isFemale() -> Bool { return type["female"]! }
}
