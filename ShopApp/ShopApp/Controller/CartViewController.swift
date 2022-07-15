//
//  CartViewController.swift
//  ShopApp
//
//  Created by Andreea Sburlea on 11.07.2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class CartViewController: UIViewController {
    // swiftlint:disable line_length
    // swiftlint:disable force_cast

    @IBOutlet private var totalLabel: UILabel!

    @IBOutlet private var cartTableView: UITableView!

    @IBOutlet private var footerView: UIView!

    lazy var dataSource = configureDataSource()
    var cartProducts = [CartProduct]()
    let ref = Database.database().reference()
    let storage = Storage.storage().reference()
    let cellIdentifier = "cartCell"

    enum Section {
        case all
    }

    @IBAction private func sendOrder(_ sender: UIButton) {
        addOrder {
            self.deleteCartOrder()
            self.updateSnapshot()
        }
    }

    @IBAction private func cartUpdated(_ sender: UIButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: self.cartTableView)
        guard let indexPath = self.cartTableView.indexPathForRow(at: buttonPosition) else { return }
        var currentQuantity = cartProducts[indexPath.row].getQuantity()

        if sender.currentTitle! == "+" {
            currentQuantity += 1
        } else {
            if currentQuantity > 0 {
            currentQuantity -= 1
            }
        }

        cartProducts[indexPath.row].setQuantity(quantity: currentQuantity)
        updateQuantity(index: indexPath.row, quantity: currentQuantity)
        self.totalLabel.text = self.getTotal()
        self.updateSnapshot()
    }

    @IBAction private func deleteCartProduct(_ sender: UIButton) {
        guard let email = Auth.auth().currentUser?.email as? String else { return }
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: self.cartTableView)
        guard let indexPath1 = self.cartTableView.indexPathForRow(at: buttonPosition) else { return }
         let key = ref.child("users/" + email.replacingOccurrences(of: ".", with: " ") + "/cart/" + cartProducts[indexPath1.row].getName() + "/" + cartProducts[indexPath1.row].getSize())
        key.removeValue { error, _ in
            print(error as Any)
        }
        cartProducts.remove(at: indexPath1.row)
        updateSnapshot()
    }
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cartTableView.dataSource = self.dataSource
        updateSnapshot()
    }

    // MARK: - ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        cartProducts.removeAll()
        self.getAllCartProducts {
            self.updateSnapshot()
        }
    }

    // MARK: - Update the cart quantity in database
    func updateQuantity(index: Int, quantity: Int) {
        guard let email = Auth.auth().currentUser?.email as? String else { return }

        // Get cart product key
        guard let key = ref.child("users/" + email.replacingOccurrences(of: ".", with: " ") + "/cart/" + cartProducts[index].getName() + "/" + cartProducts[index].getSize()).key else { return }

        // Create update command
        let childUpdates = ["users/" + email.replacingOccurrences(of: ".", with: " ") + "/cart/" + cartProducts[index].getName() + "/\(key)": String(quantity)]

        // Update
        ref.updateChildValues(childUpdates)
    }

    // MARK: - Gel all the products from the cart
    func getAllCartProducts(completion: @escaping () -> Void) {
        cartProducts.removeAll()
        getCart {
            // For each cart product get the attributes from Firebase database: "products"
            for cartProduct in self.cartProducts {
                self.ref.child("products/" + cartProduct.getName()).observeSingleEvent(of: .value, with: { snapshot in
                    guard let value = snapshot.value as? NSDictionary else { return }
                    if let price = value["price"] as? String {

                    // Get index of the cart product to be updated
                    guard let index = self.cartProducts.firstIndex(of: cartProduct) else { return }

                    // Set price of cart product
                    self.cartProducts[index].setPrice(price: Float(price)!)

                    // Set image of cart product
                    self.getCartProductImage(index: index) {
                        completion()
                    }}
                })
            }
        }
    }

    // MARK: - Get the cart from database
    func getCart(completion: @escaping () -> Void) {
        guard let email = Auth.auth().currentUser?.email as? String else { return }
        ref.child("users/" + email.replacingOccurrences(of: ".", with: " ") + "/cart").observeSingleEvent(of: .value, with: { snapshot in

            // Get "Cart" from Firebase
            guard let cartValue = snapshot.value as? NSDictionary else { return }

            // Get the attributes for each cart product
            for key in cartValue.allKeys {
                var cartProduct = CartProduct()
                cartProduct.setName(name: key as! String)
                if let propertyList = cartValue.value(forKey: key as! String) as? NSDictionary {

                    // For each size-quantity pair
                    for property in propertyList {
                        // Set size and quantity for the cart product
                        cartProduct.setSize(size: property.key as! String)
                        cartProduct.setQuantity(quantity: Int(property.value as! String)!)
                        // Add cart product to the list
                        self.cartProducts.append(cartProduct)
                    }
                } else {
                    return
                }
            }
            self.cartProducts.sort(by: { $0.getName() < $1.getName() })
            completion()
        })
    }

    // MARK: - Read images from a path
    func getCartProductImage(index: Int, completion: @escaping () -> Void) {
        // Create the image path
        let path = String("images/" + cartProducts[index].getName() + "/" + cartProducts[index].getName() + "1.jpeg")
        // Get the image
        let image = storage.child(path)
        image.getData(maxSize: 1 * 512 * 512) { data, error in
            guard let data = data, let imageData = UIImage(data: data) else {
                print(error as Any)
                return
            }
            // Set the image to the cart product
            self.cartProducts[index].setImage(image: imageData)
            completion()
        }
    }

    // MARK: - Get the cart total
    func getTotal() -> String {
        // Set a background image if the cart is empty
        if cartProducts.isEmpty {
            footerView.isHidden = true
            cartTableView.backgroundView = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width))
            cartTableView.backgroundView = UIImageView.init(image: UIImage(named: "empty"))
            cartTableView.backgroundView!.contentMode = UIView.ContentMode.scaleAspectFit

            return ""
        } else {
            footerView.isHidden = false
            cartTableView.backgroundView = UIImageView.init(image: UIImage())
            // Get the total
            var total: Float = 0
            for cartProduct in cartProducts {
                total += cartProduct.getPrice() * Float(cartProduct.getQuantity())
            }

            return String(format: "%.2f $", total)
        }
    }

    func updateSnapshot() {
        // Create a snapshot and populate the data
        var snapshot = NSDiffableDataSourceSnapshot<Section, CartProduct>()
        snapshot.appendSections([.all])
        snapshot.appendItems(cartProducts, toSection: .all)
        dataSource.apply(snapshot, animatingDifferences: false)
        self.totalLabel.text = self.getTotal()
    }

    // MARK: - Add the new order to the database
    func addOrder(completion: @escaping () -> Void) {
        guard let email = Auth.auth().currentUser?.email as? String else { return }
        ref.child("users/" + email.replacingOccurrences(of: ".", with: " ") + "/cart").observeSingleEvent(of: .value, with: { snapshot in
            // Unwrap cart value
            guard let cartValue = snapshot.value as? NSDictionary else { return }
            // Set initial status of order
            cartValue.setValue("processing", forKey: "status")
            // Set the order total
            cartValue.setValue(self.getTotal(), forKey: "total")
            // Add order by AutoId
            self.ref.child("users/" + email.replacingOccurrences(of: ".", with: " ") + "/orders").childByAutoId().setValue(cartValue)
            completion()
        })
    }

    // MARK: - Delete teh previous order from the cart
    func deleteCartOrder() {
        guard let email = Auth.auth().currentUser?.email as? String else { return }
         let key = ref.child("users/" + email.replacingOccurrences(of: ".", with: " ") + "/cart/" )
        // Remove cart
        key.removeValue { error, _ in
            print(error as Any)
            if error == nil {
                // Add alert message
                let allFieldRequired = UIAlertController(title: "Message",
                                                         message: "Your order has been successfully sent!",
                                                         preferredStyle: .alert)
                allFieldRequired.addAction(UIAlertAction(title: String(localized: "Ok", comment: "Ok"), style: .cancel, handler: nil))
                self.present(allFieldRequired, animated: true, completion: nil)
            }
        }
        cartProducts.removeAll()
        totalLabel.text = getTotal()
    }
}

extension CartViewController: UITableViewDelegate {
    func configureDataSource() -> UITableViewDiffableDataSource<Section, CartProduct> {
        let dataSource = UITableViewDiffableDataSource<Section, CartProduct>(
            tableView: cartTableView,
            cellProvider: {  tableView, indexPath, cartProduct in
                let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as? CartProductTableViewCell
                cell?.configure(image: cartProduct.getImage(),
                                name: cartProduct.getName(),
                                size: cartProduct.getSize(),
                                price: cartProduct.getPrice(),
                                quantity: cartProduct.getQuantity())

                return cell
            }
        )

        return dataSource
    }
}
