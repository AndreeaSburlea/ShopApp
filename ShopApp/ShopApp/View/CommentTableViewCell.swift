//
//  CommentTableViewCell.swift
//  ShopApp
//
//  Created by Viviana Mesaros on 17.06.2022.
//

import UIKit
import Cosmos

class CommentTableViewCell: UITableViewCell {
    @IBOutlet private var email: UILabel!
    @IBOutlet private var comment: UILabel!
    @IBOutlet private var ratingView: UIView!
    @IBOutlet weak var ratingViewWidth: NSLayoutConstraint!

    func configure(email: String, comment: String, rate: String) {
        self.email.text = email
        self.comment.text = comment
        self.configureStarView(rate: rate)
    }

    func configureStarView(rate: String) {
        let rating = Double(rate) ?? 0
        guard rating != 0.0 else {
            self.ratingViewWidth.constant = 0
            return
        }

        let starsView = CosmosView()
        starsView.settings.updateOnTouch = false
        starsView.settings.fillMode = .precise
        starsView.settings.starSize = 12
        starsView.rating = round(rating * 100) / 100.0
        self.ratingView.addSubview(starsView)
        ratingViewWidth.constant = CGFloat(starsView.frame.width)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.email.text = ""
        self.comment.text = ""
        for view in self.ratingView.subviews {
            view.removeFromSuperview()
        }
    }
}
