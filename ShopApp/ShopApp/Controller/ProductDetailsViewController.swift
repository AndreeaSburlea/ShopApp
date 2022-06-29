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
    private var comments = [String: String]()
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
        setComments()

        commentsTableView.delegate = self
        commentsTableView.dataSource = self
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
            commentViewontroller.setRoot(root: "comments/\(product.getName())/\(email.replacingOccurrences(of: ".", with: " "))")
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

    // MARK: - Size button select actoin
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

            guard let data = snapshot.value as? String else {
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

    // MARK: - Return comments
    func getComments(completion: @escaping () -> Void) {
        var productComments = [String: String]()

        ref.child("comments/\(self.product.getName())").observe(DataEventType.value, with: { snapshot in

            guard let data = snapshot.value as? [String: String] else { return }

            for value in data {
                productComments[value.key] = value.value
            }

            self.comments = productComments
            completion()
        })
    }

    // MARK: - Set commentes table
    func setComments() {
        self.getComments {
            self.tableHeight.constant = CGFloat((self.comments.count) * 54)
            self.commentsTableView.reloadData()
        }
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "comment",
                                                       for: indexPath) as? CommentTableViewCell else {
            return UITableViewCell()
        }

        let email = Array(self.comments)[indexPath.row].key.replacingOccurrences(of: " ", with: ".")
        cell.configure(email: email, comment: Array(self.comments)[indexPath.row].value)
        return cell
    }
 }
