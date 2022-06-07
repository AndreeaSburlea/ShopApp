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

    private var walkthroughPageViewController: ProductImagesPageViewController?
    private var product = Product()
    private var sizeSelected = ""
    private var favorites = [String]()
    private var cart = [String: String]()

    func setProduct(product: Product) { self.product = product }
    func setFavorites() async { self.favorites = await getFavourites() }
    func setCart() async { self.cart = await getCart() }

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
        }
    }

    // MARK: - CloseAction for close button
    @IBAction func closeAction(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - LikeAction for like button
    @IBAction func likeAction(sender: UIButton) {
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
    func getCart() async -> [String: String] {
        guard let email = Auth.auth().currentUser?.email as? String else { return [String: String]() }
        let ref = Database.database().reference()
        var productsName = [String: String]()

        let dataRead = await ref.child("users/" + email.replacingOccurrences(of: ".", with: " ") + "/cart").observeSingleEventAndPreviousSiblingKey(of: .value)

        let data = dataRead.0.value as? [String: String]

        guard let data = data else { return [String: String]() }

        for value in data {
            productsName[value.key] = value.value
        }

        return productsName
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

    // MARK: - Size button select actoin
    @IBAction func sizeSelect(sender: UIButton) {
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
    @IBAction func addToCart(sender: UIButton) {
        async {
            do {
                let name = self.product.getName()
                await self.setCart()
                var messagge = ""
                var isAdded = -1
                for data in self.cart.keys where data.elementsEqual(name) {
                    isAdded = 0
                }

                if self.sizeSelected == "" {
                    messagge = "First you have to choose a size!"
                } else {
                        guard let email = Auth.auth().currentUser?.email as? String else { return }
                        switch isAdded {
                        case -1:
                            self.cart[name] = sizeSelected
                            messagge = "Product added to cart"
                            try await Database.database().reference().child("users/" + email.replacingOccurrences(of: ".", with: " ") + "/cart").updateChildValues(self.cart)
                        default:
                           messagge = "Product is already added"
                        }
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

    func updateUI() {
        if let index = walkthroughPageViewController?.getCurrentIndex() {
            pageControl.currentPage = index
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let pageViewController = destination as? ProductImagesPageViewController {
            walkthroughPageViewController = pageViewController
            walkthroughPageViewController?.walkthroughDelegate = self
            pageViewController.setProduct(product: self.product)
        }
    }
}

extension ProductDetailsViewController: ProductImagesPageViewControllerDelegate {
    func didUpdatePageIndex(currentIndex: Int) {
        updateUI()
    }
}
