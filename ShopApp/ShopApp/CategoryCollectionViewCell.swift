//
//  CategoryCollectionViewCell.swift
//  ShopApp
//
//  Created by Andreea Sburlea on 31.05.2022.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet private var categoryImageView: UIImageView!
    @IBOutlet private var categoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    public func configure(with image: UIImage, text: String) {
        categoryImageView.image = image
        categoryLabel.text = text.capitalized
    }

    static func nib() -> UINib {
        return UINib(nibName: "CategoryCollectionViewCell", bundle: nil)
    }
}
