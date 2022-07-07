//
//  CommentImageCollectionViewCell.swift
//  ShopApp
//
//  Created by Viviana Mesaros on 05.07.2022.
//

import UIKit

class CommentImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet private var commentImage: UIImageView!

    func configure(commentImage: UIImage) {
        self.commentImage.image = commentImage
    }

    func getImage() -> UIImage { return self.commentImage.image ?? UIImage() }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    static func nib() -> UINib {
        UINib(nibName: "commentImageCell", bundle: nil)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.commentImage.image = nil
    }
}
