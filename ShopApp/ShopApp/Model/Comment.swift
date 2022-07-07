//
//  Comment.swift
//  ShopApp
//
//  Created by Viviana Mesaros on 30.06.2022.
//

import Foundation
import UIKit

struct Comment: Hashable {
    private var email: String
    private var comment: String
    private var images: [UIImage]
    private var isImage: Bool

    func getEmail() -> String { return self.email }
    func getComment() -> String { return self.comment }
    func getImages() -> [UIImage] { return self.images }
    func getIsImage() -> Bool { return self.isImage }

    mutating func setEmail(email: String) { self.email = email }
    mutating func setComment(comment: String) { self.comment = comment }
    mutating func setImages(images: [UIImage]) { self.images = images }

    init (email: String, comment: String) {
        self.email = email
        self.comment = comment
        self.images = [UIImage]()
        self.isImage = false
    }

    mutating func configure(email: String, comment: String, images: [UIImage], isImage: Bool) {
        self.email = email
        self.comment = comment
        self.images = images
        self.isImage = isImage
    }

    init() {
        self.init(email: "", comment: "")
    }
}
