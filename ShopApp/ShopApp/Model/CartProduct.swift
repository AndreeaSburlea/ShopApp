//
//  CartProduct.swift
//  ShopApp
//
//  Created by Andreea Sburlea on 16.06.2022.
//

import Foundation
import UIKit

struct CartProduct: Hashable {
    private var image: UIImage
    private var name: String
    private var size: String
    private var price: Float
    private var quantity: Int

    func getImage() -> UIImage { return self.image }
    func getName() -> String { return self.name }
    func getSize() -> String { return self.size }
    func getPrice() -> Float { return self.price }
    func getQuantity() -> Int { return self.quantity}

    mutating func setImage(image: UIImage) { self.image = image }
    mutating func setName(name: String) { self.name = name }
    mutating func setSize(size: String) { self.size = size }
    mutating func setPrice(price: Float) { self.price = price }
    mutating func setQuantity(quantity: Int) { self.quantity = quantity }

    init(image: UIImage, name: String, size: String, price: Float, quantity: Int) {
        self.image = image
        self.name = name
        self.size = size
        self.price = price
        self.quantity = quantity
    }

    mutating func configure(image: UIImage, name: String, size: String, price: Float, quantity: Int) {
        self.image = image
        self.name = name
        self.size = size
        self.price = price
        self.quantity = quantity
    }

    init() {
        self.init(image: UIImage(), name: "", size: "", price: 0, quantity: 0)
    }
}
