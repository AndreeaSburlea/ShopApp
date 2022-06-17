//
//  CommentTableViewCell.swift
//  ShopApp
//
//  Created by Viviana Mesaros on 17.06.2022.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    @IBOutlet private var email: UILabel!
    @IBOutlet private var comment: UILabel!

    func configure(email: String, comment: String) {
        self.email.text = email
        self.comment.text = comment
    }

}
