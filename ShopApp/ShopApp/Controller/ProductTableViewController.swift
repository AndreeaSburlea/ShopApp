//
//  ProoductTableViewController.swift
//  ShopApp
//
//  Created by Viviana Mesaros on 02.06.2022.
//

import UIKit
import FirebaseDatabase
import Firebase
import FirebaseStorage

class ProductTableViewController: UITableViewController {

    private var products = [Product]()
    private var ref: DatabaseReference!
    lazy var dataSource = configureDataSource()
    private var category = "Dress"

    enum Section {
        case all
    }

    func setCategory(category: String) {
        self.category = category
    }

    func configureDataSource() -> UITableViewDiffableDataSource<Section, Product > {
        let cellIdentifier = "productcell"
        let dataSource = UITableViewDiffableDataSource<Section, Product>(
            tableView: tableView,
            cellProvider: {  tableView, indexPath, product in
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ProductByCategoryCell
                cell?.configure(productName: product.getName(),
                                productPrice: product.getPrice(),
                                productSize: product.getSize(),
                                productImage: product.getImages()[0])

                return cell
            }
        )

        return dataSource
    }

    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        async {
            super.viewDidLoad()

            navigationController?.navigationBar.prefersLargeTitles = true

            await self.getAllProducts()
            tableView.dataSource = dataSource
            self.updateSnapshot()
        }
    }

    @IBAction private func backButton() {
        let storyboard = UIStoryboard(name: "HomePage", bundle: nil)
        let homeViewController = storyboard.instantiateViewController(identifier: "HomeViewController")
        let navigationController = self.navigationController
        navigationController?.setViewControllers([homeViewController], animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // To hide when scoll
        navigationController?.hidesBarsOnSwipe = true

        // Title to be large (not just in the begining )
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    func updateSnapshot(animatingChange: Bool = false) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Product>()
        snapshot.appendSections([.all])
        snapshot.appendItems(products, toSection: .all)
        dataSource.apply(snapshot, animatingDifferences: animatingChange)
    }

    // MARK: - Create an product object
    func getProductObject(dataProduct: [String: Any], name: String) -> Product {
        var product = Product()
        product.setName(name: name)
        for valueProduct in dataProduct.keys {
            switch valueProduct {
            case "category":
                var categoryData = dataProduct[valueProduct] as? String ?? ""
                if categoryData.caseInsensitiveCompare(self.category) == .orderedSame {
                    product.setCategory(category: dataProduct[valueProduct] as? String ?? "")
                } else {
                    product.setCategory(category: "")
                }
            case "price":
                product.setPrice(price: dataProduct[valueProduct] as? String ?? "")
            case "type":
                product.setType(type: dataProduct[valueProduct] as? String ?? "")
            case "size":
                product.setSize(size: dataProduct[valueProduct] as? [String] ?? [])
            default:
                return Product()
            }
        }

        return product
    }

    // MARK: - Read images from a root
    func getAllImages(root: String) async -> [UIImage] {
        var images = [UIImage]()
        let storage = Storage.storage().reference()

        for i in 1...4 {
            let roots = root + "\(i).png"
            let image = storage.child(roots)

            do {
                let data = try await image.data(maxSize: 2 * 1024 * 1024)

                guard let imageData = UIImage(data: data) else {
                    return []
                }

                images.append(imageData)
            } catch {
                print("Error from get imageFromRoot \(error)")
            }
        }

        return images
    }

    // MARK: - Read data from firebase and append in products
    func getAllProducts() async {
        self.ref = Database.database().reference()
        var product = Product()
        var root: String = "images/"

        // Get data from products table
        let dataRead = await self.ref.child("products").observeSingleEventAndPreviousSiblingKey(of: .value)

        let data = dataRead.0.value as? [String: Any]

        // Check if data is null
        guard let data = data else {
            return
        }

        // For every product in products table
        for dataKeys in data.keys {

            // Go to every product reference
            let imageData = await self.ref.child("products/\(dataKeys)").observeSingleEventAndPreviousSiblingKey(of: .value)

            // Get the snapshot from imageData and convert in [String: Any]
            let dataProduct = imageData.0.value as? [String: Any]

            // check if the product is null
            guard let dataProduct = dataProduct else {
                return
            }

            // Create a product object
            product = self.getProductObject(dataProduct: dataProduct, name: dataKeys)
            if product.getCategory() != "" {

                // Set the rot for every image
                root = "images/" + dataKeys as String + "/" + dataKeys as String

                // Set images for product
                await product.setImages(images: self.getAllImages(root: root))
                self.products.append(product)
            }
        }
    }
}
