//
//  OrderDetailTableViewCell.swift
//  ShopApp
//
//  Created by Andreea Sburlea on 13.07.2022.
//

import UIKit

class OrderDetailTableViewCell: UITableViewCell {

    @IBOutlet private var imageProduct: UIImageView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var sizeLabel: UILabel!
    @IBOutlet private var priceLabel: UILabel!
    @IBOutlet private var quantityLabel: UILabel!
    @IBOutlet private var buyButton: UIButton!

    func configure(image: UIImage, name: String, size: String, price: String, quantity: String) {
        self.imageProduct.image = image
        self.nameLabel.text = name
        self.sizeLabel.text = size
        self.priceLabel.text = price
        self.quantityLabel.text = quantity
    }
}
