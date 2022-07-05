//
//  HomeViewController.swift
//  ShopApp
//
//  Created by Andreea Sburlea on 27.05.2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class HomeViewController: UIViewController {
    // swiftlint:disable line_length
    // swiftlint:disable force_cast

    var searchController: UISearchController!
    var categoryList = [Category]()
    var categoryListType = [Category]()
    var productList = [Product]()
    var type: String!
    lazy var productsDataSource = configureDataSource()
    private let ref = Database.database().reference()
    private let storage = Storage.storage().reference()

    enum Section {
        case all
    }

    @IBOutlet private var productsTableView: UITableView!

    @IBOutlet private var categoriesCollectionView: UICollectionView!

    @IBOutlet private var segmentedControl: UISegmentedControl!

    @IBAction private func segmentedControlTapped(_ sender: Any) {
        categoryListType.removeAll()
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            for category in categoryList {
                if category.isFemale() {
                    categoryListType.append(category)
                    }
            }
            type = "female"
        case 1:
            for category in categoryList {
                if category.isMale() {
                    categoryListType.append(category)
                }
            }
            type = "male"
        default:
            break
        }
        self.categoriesCollectionView.reloadData()
    }

    // Logout the user
    @IBAction private func logout() {
        // Sign out from Google account
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }

        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(identifier: "LoginViewController")
        let navigationController = self.navigationController
        navigationController?.setViewControllers([loginViewController], animated: true)
    }

    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the navigation bar title
        if let name = Auth.auth().currentUser?.displayName as? String {
            self.navigationItem.title = "Welcome \(name)! "
        } else {
            self.navigationItem.title = "Welcome!"
        }

        searchController = UISearchController(searchResultsController: nil)
        self.navigationItem.searchController = searchController
        self.searchController.searchBar.delegate = self

        productsTableView.isHidden = true
        let cellIdentifier = "CategoryCollectionViewCell"
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width / 3, height: 120)
        categoriesCollectionView.collectionViewLayout = layout

        // Without separator in tableView
        productsTableView.separatorStyle = .none

        self.categoriesCollectionView.register(CategoryCollectionViewCell.nib(), forCellWithReuseIdentifier: cellIdentifier)
        self.categoriesCollectionView.delegate = self
        self.categoriesCollectionView.dataSource = self

        productsTableView.dataSource = productsDataSource
        productsTableView.delegate = self

        self.getAllCategories()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }

    // MARK: - Get all categories from database
    func getAllCategories() {
        // Read data from database/categories/
        ref.child("categories/").observeSingleEvent(of: .value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            // Unwrap the dictionary
            if let categories = value {
                // For each category:
                for category in categories.allKeys {
                    var newCategory = Category()
                    // Set name
                    newCategory.setName(name: category as! String)
                    // Get type and image as NSDictionary
                    if let properties = categories[category] as? NSDictionary {
                        // Set type
                        if let type = properties["type"] as? [String: Bool] {
                            newCategory.setType(type: type)
                        }
                        // Get image path
                        if let path = properties["image"] as? String {
                        // Call the getImage method and process the image in the completion block
                            self.retrieveImage(path: path, completion: { image in
                                // Set image of the category
                                newCategory.setImage(image: image)
                                // Append the category to the list
                                self.categoryList.append(newCategory)
                                // If we retrieved all the categories, sort the list and reload data
                                if self.categoryList.count == categories.count {
                                    self.categoryList.sort(by: { $0.getName() < $1.getName() })
                                    self.segmentedControlTapped(self.segmentedControl)
                                }
                            })
                        }
                    }
                }
            }
        }) { error in
            print(error.localizedDescription)
          }
    }

    // MARK: - Get the image based on the path
    func retrieveImage(path: String, completion: @escaping (UIImage) -> Void) {
        let image = storage.child(path)
        image.getData(maxSize: 1 * 512 * 512) { data, error in
            guard let data = data, let imageData = UIImage(data: data) else {
                print(error as Any)
                return
            }
            completion(imageData)
        }
    }

    func updateSnapshot(animatingChange: Bool = false) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Product>()
        snapshot.appendSections([.all])
        snapshot.appendItems(self.productList, toSection: .all)
        self.addBackgroundImageTableView()
        productsDataSource.apply(snapshot, animatingDifferences: animatingChange)
    }

    // MARK: - Return all the products based on search criteria
    func getSearchedProducts() {
        productList.removeAll()
        updateSnapshot()
        ref.child("products/").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            guard let data = snapshot.value as? [String: Any] else { return }
            // Get the text from search bar
            guard let searchText = self.searchController.searchBar.text as? String else { return }
            // For each product name
            for dataKeys in data.keys {
                // Unwrap product properties into product
                if let product = data[dataKeys] as? [String: Any] {
                    // Unwrap product name into title
                    if let title = dataKeys as? String {
                        // If product name contains the searched criteria
                        if title.contains(searchText.uppercased()) {
                            // Create new product with given properties
                            var newProduct = self.getProductObject(dataProduct: product, name: dataKeys)
                            // Set image of product
                            self.retrieveImage(path: "images/\(dataKeys)/\(dataKeys)1.jpeg") { image in
                                newProduct.setImages(images: [image])
                                // Add product to product list
                                self.productList.append(newProduct)
                                self.updateSnapshot()
                            }
                        }
                    }
                }
            }
        })
    }

    // MARK: - Create and return a product with properties
    func getProductObject(dataProduct: [String: Any], name: String) -> Product {
        var product = Product()
        product.setName(name: name)
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

    // Add an image for an empty product list
    func addBackgroundImageTableView() {
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        if self.productList.isEmpty {
            imageViewBackground.image = UIImage(named: "empty")
        } else {
            imageViewBackground.image = UIImage()
        }

        imageViewBackground.contentMode = UIView.ContentMode.scaleAspectFit
        self.productsTableView.backgroundView = imageViewBackground
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        let storyboard = UIStoryboard(name: "ProductsByCategory", bundle: nil)
        guard let productController = storyboard.instantiateViewController(withIdentifier: "ProductTableViewController") as? ProductTableViewController else {
            return
        }

        productController.setCategory(category: categoryListType[indexPath.row].getName())
        productController.setType(type: type)
        let navigationController = self.navigationController
        navigationController?.setViewControllers([productController], animated: true)
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categoryListType.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdenntifier = "CategoryCollectionViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdenntifier, for: indexPath) as! CategoryCollectionViewCell
        cell.configure(with: categoryListType[indexPath.row].getImage(), text: categoryListType[indexPath.row].getName())

        return cell
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: UIScreen.main.bounds.width / 3, height: 150)
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        categoriesCollectionView.isHidden = true
        productsTableView.isHidden = false
        segmentedControl.isHidden = true
        getSearchedProducts()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        productList.removeAll()
        updateSnapshot()
        categoriesCollectionView.isHidden = false
        productsTableView.isHidden = true
        segmentedControl.isHidden = false
    }
}

extension HomeViewController: UITableViewDelegate {
    func configureDataSource() -> UITableViewDiffableDataSource<Section, Product > {
        let cellIdentifier = "searchProductCell"
        let dataSource = UITableViewDiffableDataSource<Section, Product>(
            tableView: productsTableView,
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "ProductsByCategory", bundle: nil)
        if let indexPath = tableView.indexPathForSelectedRow {
            guard let destinationController = storyboard.instantiateViewController(withIdentifier: "ProductDetails") as? ProductDetailsViewController else {
                return
            }

            destinationController.setProduct(product: self.productList[indexPath.row])
            self.present(destinationController, animated: true, completion: nil)
        }
    }
}
