//
//  CartProductCollectionViewCell.swift
//  ShopApp
//
//  Created by Andreea Sburlea on 16.06.2022.
//

import UIKit

class CartProductTableViewCell: UITableViewCell {

    @IBOutlet private var productImage: UIImageView!
    @IBOutlet private var productName: UILabel!
    @IBOutlet private var productSize: UILabel!
    @IBOutlet private var productPrice: UILabel!
    @IBOutlet private var productQuantity: UILabel!
    @IBOutlet private var minusButton: UIButton!
    @IBOutlet private var plusButton: UIButton!
    @IBOutlet private var deleteButton: UIButton!

    func configure(image: UIImage, name: String, size: String, price: Float, quantity: Int) {
        self.productImage.image = image
        self.productName.text = name
        self.productSize.text = size
        self.productPrice.text = String(format: "%.2f", price)
        self.productQuantity.text = String(quantity)
        if quantity == 0 {
            self.deleteButton.isHidden = false
        } else {
            self.deleteButton.isHidden = true
        }
        self.minusButton.setTitle("-", for: .normal)
        self.plusButton.setTitle("+", for: .normal)
    }
}
