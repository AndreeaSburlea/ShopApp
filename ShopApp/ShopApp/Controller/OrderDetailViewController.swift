//
//  OrderDetailViewController.swift
//  ShopApp
//
//  Created by Andreea Sburlea on 13.07.2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class OrderDetailViewController: UIViewController {
    // swiftlint:disable line_length
    // swiftlint:disable force_cast

    lazy var dataSource = configureDataSource()
    var cartProducts = [CartProduct]()
    let ref = Database.database().reference()
    let storage = Storage.storage().reference()
    let cellIdentifier = "orderDetailCell"
    var orderNumber: String!

    enum Section {
        case all
    }
    func setOrder(order: String) { self.orderNumber = order }

    @IBOutlet private var orderDetailTableView: UITableView!

    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.orderDetailTableView.dataSource = self.dataSource
        getOrderProducts {
            self.updateSnapshot()
        }
    }
    
    @IBAction private func buyAgain(_ sender: UIButton) {
        // Get index of the product tapped
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: self.orderDetailTableView)
        guard let indexPath1 = self.orderDetailTableView.indexPathForRow(at: buttonPosition) else { return }
        guard let email = Auth.auth().currentUser?.email as? String else { return }
        let root = "users/\(email.replacingOccurrences(of: ".", with: "  "))/cart/\(self.cartProducts[indexPath1.row].getName())/\(self.cartProducts[indexPath1.row].getSize())"
        self.ref.child(root).observeSingleEvent(of: DataEventType.value, with: { snapshot in

            guard let data = snapshot.value as? String else {
                // Add product to cart
                self.ref.child(root).setValue("1")
                return
            }
            // Increase quantity of existing product in cart
            let quantity = Int(data) ?? 0
            self.ref.child("\(root)").setValue("\(quantity + 1)")
        })
    }

    // MARK: - Get the products from order
    func getOrderProducts(completion: @escaping () -> Void) {
        guard let email = Auth.auth().currentUser?.email as? String else { return }
        ref.child("users/" + email.replacingOccurrences(of: ".", with: " ") + "/orders/" + orderNumber).observeSingleEvent(of: .value, with: { snapshot in

            // Get Order from Firebase
            guard let orderValue = snapshot.value as? NSDictionary else { return }
            // For each key under orderNumber
            for key in orderValue.allKeys {
                // Unwrap key
                if let keyValue = key as? String {
                    switch keyValue {
                    case "status":
                        break
                    case "total":
                        break
                    // If we got a product
                    default:
                        // Create new cart product
                        var cartProduct = CartProduct()
                        // Set the name of the cart product
                        cartProduct.setName(name: keyValue)
                        // Call function to get the price
                        self.getProductPrice(productId: keyValue) { price in
                            // Set price
                            cartProduct.setPrice(price: price)
                            // Get product image
                            self.getCartProductImage(productId: keyValue, completion: {image in
                                // Set image
                                cartProduct.setImage(image: image)
                                // Get size and quantity
                                if let sizeQuan = orderValue[keyValue] as? NSDictionary {
                                    for(key2, value) in sizeQuan {
                                        cartProduct.setSize(size: key2 as! String)
                                        cartProduct.setQuantity(quantity: Int(value as! String)!)
                                    }
                                    // Add Cart Product to list of Cart Products
                                    self.cartProducts.append(cartProduct)
                                }
                                completion()
                            })
                        }
                }
            }}
        })
    }

    // MARK: - Get the products price from "products"
    func getProductPrice(productId: String, completion: @escaping (Float) -> Void) {
        // Define price variable as float
        var price: Float!
        // Get product properties
        ref.child("products/" + productId).observeSingleEvent(of: .value, with: { snapshot in
            // Unwrap product properties
            if let properties = snapshot.value as? NSDictionary {
                price = Float(properties["price"] as! String)
                completion(price)
            }
        })
    }

    // MARK: - Read the images from a path
    func getCartProductImage(productId: String, completion: @escaping (UIImage) -> Void) {
        // Create the image path
        let path = String("images/" + productId + "/" + productId + "1.jpeg")
        // Get the image
        let image = storage.child(path)
        image.getData(maxSize: 1 * 512 * 512) { data, error in
            guard let data = data, let imageData = UIImage(data: data) else {
                print(error as Any)
                return
            }
            // Return the image to the order product
            completion(imageData)
        }
    }

    func updateSnapshot() {
        // Create a snapshot and populate the data
        var snapshot = NSDiffableDataSourceSnapshot<Section, CartProduct>()
        snapshot.appendSections([.all])
        snapshot.appendItems(cartProducts, toSection: .all)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension OrderDetailViewController: UITableViewDelegate {
    func configureDataSource() -> UITableViewDiffableDataSource<Section, CartProduct> {
        let dataSource = UITableViewDiffableDataSource<Section, CartProduct>(
            tableView: orderDetailTableView,
            cellProvider: {  tableView, indexPath, cartProduct in
                let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as? OrderDetailTableViewCell
                cell?.configure(image: cartProduct.getImage(),
                                name: cartProduct.getName(),
                                size: cartProduct.getSize(),
                                price: String(cartProduct.getPrice()),
                                quantity: String(cartProduct.getQuantity()))

                return cell
            }
        )

        return dataSource
    }
}
