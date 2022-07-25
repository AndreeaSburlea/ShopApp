//
//  CommentImageTableViewCell.swift
//  ShopApp
//
//  Created by Viviana Mesaros on 30.06.2022.
//

import UIKit
import FirebaseStorage
import Cosmos

protocol ViewCommentImagesDelegate: AnyObject { func viewCommentImages(images: [UIImage]) }

class CommentImageTableViewCell: UITableViewCell {

    @IBOutlet private var email: UILabel!
    @IBOutlet private var comment: UILabel!
    @IBOutlet private var ratingView: UIView!
    @IBOutlet private var commentImagesCollectionView: UICollectionView!
    @IBOutlet weak var ratingViewWidth: NSLayoutConstraint!

    private var commentImages = [UIImage]()
    private var commentImagesCopy = [UIImage]()

    weak var commentImagesDelegate: ViewCommentImagesDelegate?

    func configure(email: String, comment: String, commentImages: [UIImage], rate: String) {
        self.email.text = email
        self.comment.text = comment
        self.configureStarView(rate: rate)
        self.commentImages = commentImages
        self.commentImagesCopy = commentImages
        self.commentImagesCollectionView.reloadData()
        self.reloadDataIfThereIsMoreImages()
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
        starsView.rating = round(rating * 10) / 10.0
        self.ratingView.addSubview(starsView)
    }

    func reloadDataIfThereIsMoreImages() {
        DispatchQueue.main.async {
            let index = self.commentImagesCollectionView.visibleCells.count
            if index != self.commentImages.count {
                self.commentImages[index - 1] = UIImage(systemName: "ellipsis") ?? UIImage()
                self.commentImagesCollectionView.reloadData()
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.email.text = ""
        self.comment.text = ""
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        commentImagesCollectionView.delegate = self
        commentImagesCollectionView.dataSource = self
    }

    @objc private func handler(_ sender: UITapGestureRecognizer) {
        commentImagesDelegate?.viewCommentImages(images: self.commentImagesCopy)
    }

}

extension CommentImageTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return self.commentImages.count
     }

     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

         guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "commentImageCell", for: indexPath) as? CommentImageCollectionViewCell else {
             return UICollectionViewCell()
         }

         cell.configure(commentImage: self.commentImages[indexPath.row])

         // Add gesture to images collectiioon view (when it is tapped to show all images)
         let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handler(_:)))
         tapGesture.numberOfTapsRequired = 1
         cell.addGestureRecognizer(tapGesture)
         return cell
     }
 }
