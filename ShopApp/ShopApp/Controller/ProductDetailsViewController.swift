//
//  ProductDetailView.swift
//  ShopApp
//
//  Created by Viviana Mesaros on 06.06.2022.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class ProductDetailsViewController: UIViewController {
    @IBOutlet private var pageControl: UIPageControl!
    @IBOutlet private var priceLabel: UILabel!
    @IBOutlet private var addToCartMessageLabel: UILabel!
    @IBOutlet private var sizeButtons: [UIButton]!
    @IBOutlet private var likeButton: UIButton!
    @IBOutlet private var commentsTableView: UITableView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!

    private var walkthroughPageViewController: ProductImagesPageViewController?
    private var product = Product()
    private var sizeSelected = ""
    private var isFavorite = false
    private var comments = [Comment]()
    private var ref = Database.database().reference()

    func setProduct(product: Product) { self.product = product }

    func configureMessageLabel() {
        addToCartMessageLabel.layer.backgroundColor = UIColor.systemGray6.cgColor
        addToCartMessageLabel.layer.masksToBounds = true
        addToCartMessageLabel.layer.cornerRadius = 9
    }

    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMessageLabel()
        setFavoritesButton()
        priceLabel.text = " $ " + self.product.getPrice()
        configureSizes()
        getComments()

        commentsTableView.rowHeight = UITableView.automaticDimension
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.commentsTableView.reloadData()
    }

    // MARK: - Auto sizing commentTable
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.commentsTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.commentsTableView.removeObserver(self, forKeyPath: "contentSize")
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            if let newValue = change?[.newKey] {
                guard let newSize = newValue as? CGSize else { return }
                self.tableHeight.constant = newSize.height
            }
        }
    }

    // MARK: - Prepare - segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let pageViewController = destination as? ProductImagesPageViewController {
            walkthroughPageViewController = pageViewController
            walkthroughPageViewController?.walkthroughDelegate = self
            pageViewController.setProduct(product: self.product)
        }

        if let commentViewontroller = destination as? AddCommentViewController {
            guard let email = Auth.auth().currentUser?.email as? String else { return }
            let emailKey = email.replacingOccurrences(of: ".", with: " ")
            commentViewontroller.setRoots(commentRoot: "comments/\(product.getName())/\(emailKey)",
                                          imageRoot: "commentsImage/\(product.getName())/\(emailKey)")
        }
    }

    // MARK: - CloseAction for close button
    @IBAction private func closeAction(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - LikeAction for like button
    @IBAction private func likeAction(sender: UIButton) {
        self.favoritesAction()
    }

    // MARK: - Add to cart action
    @IBAction private func addToCart(sender: UIButton) {
        if self.sizeSelected == "" {
            let allFieldRequired = UIAlertController(title: "Message",
                                                     message: "First you have to choose a size!",
                                                     preferredStyle: .alert)
            self.present(allFieldRequired, animated: true, completion: nil)

            // dismiss after 2 seconds
            let timeOfDismissal = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: timeOfDismissal) {
                allFieldRequired.dismiss(animated: true, completion: nil)
            }
        } else {
            self.addToCartAction(size: self.sizeSelected) { text in
                self.addToCartMessageLabel.text = text
                self.addToCartMessageLabel.alpha = 0.65
                UIView.animate(withDuration: 4.0) {  self.addToCartMessageLabel.alpha = 0 }
            }
        }
    }

    // MARK: - Size button select action
    @IBAction private func sizeSelect(sender: UIButton) {
        guard sender.tintColor != UIColor.systemGray3 else {
            return
        }

        for i in 0...5 {
            sizeButtons[i].backgroundColor = .systemGray6
        }

        sender.backgroundColor = .systemGray3
        guard let name = sender.titleLabel?.text as? String else {
            return
        }

        self.sizeSelected = name
    }

    func favoritesAction() {
        guard let email = Auth.auth().currentUser?.email as? String else { return }
        let emailRef = email.replacingOccurrences(of: ".", with: " ")

        if !isFavorite {
            self.ref.child("users/\(emailRef)/favourites/\(self.product.getName())").setValue("favorite")
        } else {
            Database.database().reference().child("users/\(emailRef)/favourites/\(self.product.getName())").removeValue()
        }
    }

    // MARK: - Set the like button in the beginning
    func setFavoritesButton() {
        guard let email = Auth.auth().currentUser?.email as? String else { return }
        let emailRef = email.replacingOccurrences(of: ".", with: " ")

        self.ref.child("users/\(emailRef)/favourites/\(self.product.getName())").observe(DataEventType.value, with: { snapshot in

            guard let _ = snapshot.value as? String else {
                self.likeButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
                self.isFavorite = false
                return
            }

            self.likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
            self.isFavorite = true
        })
    }

    func addToCartAction(size: String, completion: @escaping (String) -> Void) {
        guard let email = Auth.auth().currentUser?.email as? String else { return }

        let emailRef = email.replacingOccurrences(of: ".", with: " ")
        let root = "users/\(emailRef)/cart/\(self.product.getName())/\(size)"
        self.ref.child(root).observeSingleEvent(of: DataEventType.value, with: { snapshot in

            guard let data = snapshot.value as? String else {
                self.ref.child(root).setValue("1")
                completion("Product added to cart!")
                return
            }

            let quantity = Int(data) ?? 0
            self.ref.child("\(root)").setValue("\(quantity + 1)")
            completion("Product added to cart!")
        })
    }

    func getCommentImage(roots: [String], completion: @escaping ([UIImage], Bool) -> Void) {
        var images = [UIImage]()
        for root in roots {
            Storage.storage().reference().child(root).getData(maxSize: 500 * 512 * 512) { data, error in
                guard let data = data, let imageData = UIImage(data: data) else {
                    completion([UIImage](), false)
                    return
                }

                images.append(imageData)

                if images.count == roots.count {
                    completion(images, true)
                }
            }
        }
    }

    // MARK: - Return comments
    func getComments() {
        var comment = Comment()

        ref.child("comments/\(self.product.getName())").observe(DataEventType.value, with: { snapshot in

            guard let data = snapshot.value as? [String: [String: [String]]] else { return }
            self.comments.removeAll()

            let values = Array(data.keys)
            if !values.isEmpty {
                for i in 0...(values.count - 1) {
                    guard let emailData = data[values[i]] else { return }

                    // Get comments and images
                    for commentData in emailData {
                        self.getCommentImage(roots: commentData.value) { images, isImage in
                            comment.configure(email: values[i], comment: commentData.key, images: images, isImage: isImage)
                            self.comments.append(comment)
                            self.commentsTableView.reloadData()
                        }
                    }
                }
            }
       })
    }

    // MARK: - Custom size buttons
    func configureSizes() {
        for size in self.product.getSize() {
            switch size {
            case "XS" :
                sizeButtons[0].tintColor = .clear
            case "S" :
                sizeButtons[1].tintColor = .clear
            case "M" :
                sizeButtons[2].tintColor = .clear
            case "L" :
                sizeButtons[3].tintColor = .clear
            case "XL" :
                sizeButtons[4].tintColor = .clear
            case "XLL" :
                sizeButtons[5].tintColor = .clear
            default:
                return
            }
        }
    }

    func updateUI() {
        if let index = walkthroughPageViewController?.getCurrentIndex() {
            pageControl.currentPage = index
        }
    }

    func showCommentImage(images: [UIImage]){
        guard let commentImagesViewController = self.storyboard?.instantiateViewController(withIdentifier: "CommentImagesViewController") as? CommentImagesViewController else { return }

        commentImagesViewController.setImages(images: images)
        present(commentImagesViewController, animated: true, completion: nil)
    }
}

extension ProductDetailsViewController: ProductImagesPageViewControllerDelegate {
    func didUpdatePageIndex(currentIndex: Int) {
        updateUI()
    }
}

extension ProductDetailsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.comments[indexPath.row].getIsImage() == false {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "comment",
                                                           for: indexPath) as? CommentTableViewCell else {
                return UITableViewCell()
            }

            let email = self.comments[indexPath.row].getEmail().replacingOccurrences(of: " ", with: ".")
            cell.configure(email: email, comment: self.comments[indexPath.row].getComment())
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "commentImage",
                                                           for: indexPath) as? CommentImageTableViewCell else {
                return UITableViewCell()
            }

            cell.configure(email: self.comments[indexPath.row].getEmail(),
                           comment: self.comments[indexPath.row].getComment(),
                           commentImages: self.comments[indexPath.row].getImages())

            cell.commentImagesDelegate = self
            return cell
        }
    }
}

extension ProductDetailsViewController: ViewCommentImagesDelegate {
    func viewCommentImages(images: [UIImage]) {
        showCommentImage(images: images)
    }
}
