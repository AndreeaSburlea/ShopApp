//
//  ProductByCategoryCell.swift
//  ShopApp
//
//  Created by Viviana Mesaros on 30.05.2022.
//

import UIKit

class ProductByCategoryCell: UITableViewCell {
    @IBOutlet private var productImage: UIImageView!
    @IBOutlet private var productName: UILabel!
    @IBOutlet private var productPrice: UILabel!
    @IBOutlet private var productSize: UILabel!

    func configure(productName: String, productPrice: String, productSize: [String], productImage: UIImage) {
        self.productImage.image = productImage
        self.productName.text = productName
        self.productPrice.text = productPrice
        var finalSize = ""
        for size in productSize {
            finalSize += size + " "
        }
        self.productSize.text = finalSize
    }
}
