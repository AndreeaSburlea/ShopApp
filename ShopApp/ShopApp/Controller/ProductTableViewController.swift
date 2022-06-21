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

    @IBOutlet private var emptyProducts: UIView!

    private var products = [Product]()
    private var ref: DatabaseReference!
    lazy var dataSource = configureDataSource()
    private var category = "Dress"
    private var indicatorView = UIActivityIndicatorView(style: .medium)

    enum Section { case all }

    func setCategory(category: String) { self.category = category }

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
        super.viewDidLoad()

        // Add an activity indicator
        indicatorView = self.activityIndicator(style: .medium, center: self.view.center)
        view.addSubview(indicatorView)
        indicatorView.startAnimating()
        
        self.getProducts()

        navigationController?.navigationBar.prefersLargeTitles = true

        tableView.dataSource = dataSource
    }

    // MARK: - Prepare - segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            if let indexPath = tableView.indexPathForSelectedRow {
                guard let destinationController = segue.destination as? ProductDetailsViewController else {
                    return
                }

                destinationController.setProduct(product: self.products[indexPath.row])
            }
        }
    }

    // MARK: - Activity indicator configure
    private func activityIndicator(style: UIActivityIndicatorView.Style = .medium,
                                   frame: CGRect? = nil,
                                   center: CGPoint? = nil) -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView(style: style)
        if let frame = frame { activityIndicatorView.frame = frame }
        if let center = center { activityIndicatorView.center = center }
        return activityIndicatorView
    }

    // MARK: - Back button action
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

    // MARK: - Update Snapshot
    func updateSnapshot(animatingChange: Bool = false) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Product>()
        snapshot.appendSections([.all])
        snapshot.appendItems(self.products, toSection: .all)
        dataSource.apply(snapshot, animatingDifferences: animatingChange)
    }

    // MARK: - Create an product object
    func getProductObject(dataProduct: [String: Any], name: String) -> Product {
        var product = Product()
        product.setName(name: name)
        product.setCategory(category: self.category)
        for valueProduct in dataProduct.keys {
            switch valueProduct {
            case "category":
                product.setCategory(category: dataProduct[valueProduct] as? String ?? "")
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

    // MARK: - Get image for a specific product
    func getImages(root: String, completion: @escaping (UIImage) -> Void) {
        let storage = Storage.storage().reference()
        let image = storage.child(root)

        image.getData(maxSize: 1 * 512 * 512) { data, error in
            guard let data = data, let imageData = UIImage(data: data) else {
                print(error as Any)
                return
            }

            completion(imageData)
        }
    }

    // MARK: - Get products from database
    func getProducts() {
        let ref = Database.database().reference().child("products").queryOrdered(byChild: "category").queryEqual(toValue : self.category)

        ref.observe(DataEventType.value, with: { snapshot in

            guard let data = snapshot.value as? [String: Any] else {
                self.indicatorView.stopAnimating()
                self.tableView.backgroundView = self.emptyProducts
                self.tableView.backgroundView?.isHidden = self.products.isEmpty ? false : true
                print("not valid data")
                return
            }

            // For every product in products table
            for dataKeys in data.keys {
                guard let product = data[dataKeys] as? [String: Any] else { return }
                self.getImages(root: "images/\(dataKeys)/\(dataKeys)1.jpeg") { image in
                    var product = self.getProductObject(dataProduct: product, name: dataKeys)
                    product.setImages(images: [image])

                    self.products.append(product)

                    if(self.products.count == data.keys.count) {
                        self.updateSnapshot()
                        self.indicatorView.stopAnimating()
                    }
                }
            }
        })
    }
}
