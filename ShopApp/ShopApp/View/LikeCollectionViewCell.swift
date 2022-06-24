//
//  LikeCollectionViewCell.swift
//  ShopApp
//
//  Created by Viviana Mesaros on 24.06.2022.
//

import UIKit

class LikeCollectionViewCell: UICollectionViewCell {
    @IBOutlet private var nameProduct: UILabel!
    @IBOutlet private var imageProduct: UIImageView!

    func configure(nameProduct: String, imageProduct: UIImage){
        self.imageProduct.image = imageProduct
        self.nameProduct.text = nameProduct
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    static func nib() -> UINib {
        UINib(nibName: "LikeCollectionViewCell", bundle: nil)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageProduct.image = nil
        self.nameProduct.text = ""
    }
}
