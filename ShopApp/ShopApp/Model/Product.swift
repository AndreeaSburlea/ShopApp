//
//  Product.swift
//  ShopApp
//
//  Created by Viviana Mesaros on 30.05.2022.
//

import Foundation
import UIKit

struct Product: Hashable {
    private var name: String
    private var price: String
    private var size: [String]
    private var category: String
    private var type: String
    private var images: [UIImage]

    func getName() -> String { return self.name }
    func getCategory() -> String { return self.category }
    func getType() -> String { return self.type }
    func getPrice() -> String { return self.price }
    func getSize() -> [String] { return self.size }
    func getImages() -> [UIImage] { return self.images }

    mutating func setName(name: String) { self.name = name }
    mutating func setCategory(category: String) { self.category = category }
    mutating func setType(type: String) { self.type = type }
    mutating func setPrice(price: String) { self.price = price }
    mutating func setImages(images: [UIImage]) { self.images = images }
    mutating func setSize(size: [String]) { self.size = size }


    init(name: String, price: String, size: [String], category: String, type: String, images: [UIImage]) {
        self.category = category
        self.name = name
        self.type = type
        self.price = price
        self.images = images
        self.size = size
    }

    mutating func configure(name: String, price: String, size: [String], category: String, type: String) {
        self.category = category
        self.name = name
        self.type = type
        self.price = price
        self.size = size
    }

    init() {
        self.init(name: "", price: "", size: [], category: "", type: "", images: [])
    }
}
