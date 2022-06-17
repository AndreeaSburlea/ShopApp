//
//  ProductDetailView.swift
//  ShopApp
//
//  Created by Viviana Mesaros on 06.06.2022.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ProductDetailsViewController: UIViewController {

    @IBOutlet private var pageControl: UIPageControl!
    @IBOutlet private var priceLable: UILabel!
    @IBOutlet private var sizeButtons: [UIButton]!
    @IBOutlet private var likeButton: UIButton!
    @IBOutlet private var commentsTableView: UITableView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!

    private var walkthroughPageViewController: ProductImagesPageViewController?
    private var product = Product()
    private var sizeSelected = ""
    private var favorites = [String]()
    private var cart = [String: [String: String]]()
    private var comments = [String: String]()

    func setProduct(product: Product) { self.product = product }
    func setFavorites() async { self.favorites = await getFavourites() }
    func setCart() async { self.cart = await getCart() }
    func setComments() async { self.comments = await getComments() }

    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        async {
            if await self.getFavoriteProductIndex() == -1 {
                likeButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
            } else {
                likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
            }

            self.priceLable.text = " $ " + self.product.getPrice()
            self.sizeFunction()
            await self.setComments()

            tableHeight.constant = CGFloat((self.comments.count) * 54)
            self.commentsTableView.delegate = self
            self.commentsTableView.dataSource = self
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
            commentViewontroller.setRoot(root: "comments/\(product.getName())/\(email.replacingOccurrences(of: ".", with: " "))")
        }
    }

    // MARK: - CloseAction for close button
    @IBAction private func closeAction(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - LikeAction for like button
    @IBAction private func likeAction(sender: UIButton) {
        async {
            do {
                let name = self.product.getName()
                let indexFav = await self.getFavoriteProductIndex()
                guard let email = Auth.auth().currentUser?.email as? String else { return }
                if indexFav != -1 {
                    likeButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
                    favorites.remove(at: indexFav)
                } else {
                    likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
                    favorites.append(name)
                }

                try await Database.database().reference().child("users/" + email.replacingOccurrences(of: ".", with: " ") + "/favourites").updateChildValues(["products": favorites])
            } catch {
                print(error)
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

    // MARK: - Add to cart action
    @IBAction private func addToCart(sender: UIButton) {
        async {
            do {
                let name = self.product.getName()
                await self.setCart()
                var messagge = ""
                var isAdded = -1
                var quantityForProduct = 0

                for data in self.cart.keys where data.elementsEqual(name) {
                    guard let sizeForProduct = cart[data] else { return }
                    let size = sizeForProduct["size"]
                    if sizeSelected == size {
                        guard let quantity = sizeForProduct["quantity"] else { return }
                        quantityForProduct =  Int(quantity) ?? 0
                        isAdded = 0
                    } else { isAdded = 1 }
                }

                if self.sizeSelected == "" {
                    messagge = "First you have to choose a size!"
                } else {
                        guard let email = Auth.auth().currentUser?.email as? String else { return }
                        switch isAdded {
                        case -1:
                            messagge = "Product added to cart!"
                        case 1:
                            messagge = "The size was changed!"
                        case 0:
                            messagge = "The quantity is changed!"
                        default:
                           messagge = "Error from add to cart"
                        }

                    try await Database.database().reference().child("users/" + email.replacingOccurrences(of: ".", with: " ") + "/cart/\(product.getName())").setValue(["size": sizeSelected, "quantity": "\(quantityForProduct + 1)"])
                }

                let allFieldRequired = UIAlertController(title: "Message",
                                                         message: messagge,
                                                         preferredStyle: .alert)
                allFieldRequired.addAction(UIAlertAction(title: String(localized: "Ok", comment: "Ok"), style: .cancel, handler: nil))
                present(allFieldRequired, animated: true, completion: nil)
            } catch {
                print(error)
            }
        }
    }


    // MARK: - Return favorites from user
    func getFavourites() async -> [String] {
        guard let email = Auth.auth().currentUser?.email as? String else { return [String]() }
        let ref = Database.database().reference()
        var productsName = [String]()

        let dataRead = await ref.child("users/" + email.replacingOccurrences(of: ".", with: " ") + "/favourites/products").observeSingleEventAndPreviousSiblingKey(of: .value)

        let data = dataRead.0.value as? [String]
        guard let data = data else { return [String]() }

        for value in data {
            productsName.append(value)
        }

        return productsName
    }

    // MARK: - Return cart from user
    func getCart() async -> [String: [String: String]] {
        guard let email = Auth.auth().currentUser?.email as? String else { return [String: [String: String]]() }
        let ref = Database.database().reference()
        var productsName = [String: [String: String]]()

        let dataRead = await ref.child("users/" + email.replacingOccurrences(of: ".", with: " ") + "/cart").observeSingleEventAndPreviousSiblingKey(of: .value)

        let data = dataRead.0.value as? [String: Any]

        guard let data = data else { return [String: [String: String]]() }

        // For every product get quantity and size
        for productName in data.keys {
            let productValues = await ref.child("users/" + email.replacingOccurrences(of: ".", with: " ") + "/cart/\(productName)").observeSingleEventAndPreviousSiblingKey(of: .value)

            let productData = productValues.0.value as? [String: String]

            guard let productData = productData else { return [String: [String: String]]() }

            var sizeQuantity = [String: String]()
            for sizeQuantityData in productData {
                sizeQuantity[sizeQuantityData.key] = sizeQuantityData.value
            }

            productsName[productName] = sizeQuantity
        }

        return productsName
    }

    // MARK: - Return comments
    func getComments() async -> [String: String] {
        let ref = Database.database().reference()
        var productComments = [String: String]()

        let dataRead = await ref.child("comments/\(product.getName())").observeSingleEventAndPreviousSiblingKey(of: .value)

        let data = dataRead.0.value as? [String: String]

        guard let data = data else { return [String: String]() }

        for value in data {
            productComments[value.key] = value.value
        }

        return productComments
    }

    // MARK: - Return index if current product is favorite
    func getFavoriteProductIndex() async -> Int {
        await self.setFavorites()
        let name = self.product.getName()
        if self.favorites.isEmpty {
            return -1
        }

        for i in 0...(self.favorites.count - 1) {
            if self.favorites[i] == name {
                return i
            }
        }

        return -1
    }

    // MARK: - Custom size buttons
    func sizeFunction() {
        self.priceLable.text = self.product.getPrice()
        self.priceLable.textColor = UIColor.systemRed
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
