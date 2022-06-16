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

    var categoryList = [Category]()
    private let ref = Database.database().reference()
    private let storage = Storage.storage().reference()

    enum Section {
        case all
    }

    @IBOutlet private var collectionView: UICollectionView!

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

        let cellIdentifier = "CategoryCollectionViewCell"
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width / 3, height: 120)
        collectionView.collectionViewLayout = layout

        self.collectionView.register(CategoryCollectionViewCell.nib(), forCellWithReuseIdentifier: cellIdentifier)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.getAllCategories()
    }

    // MARK: - Get all categories from database
    func getAllCategories() {
        // Read data from database/categories/
        ref.child("categories/").observeSingleEvent(of: .value, with: { snapshot in
            // Get categories and images as dictionary
            let value = snapshot.value as? [String: String]
            // Unwrap the dictionary
            if let categories = value {
                // For each category element get the attributes
                for category in categories {
                    var newCategory = Category()
                    // Set the name of category
                    newCategory.setName(name: category.key)
                    // Create the path to retrieve the image
                    let path = category.value as String
                    // Call the getImage method and process the image in the completion block
                    self.getImage(path: path, completion: { image in
                        // Set image of the category
                        newCategory.setImage(image: image)
                        // Append the category to the list
                        self.categoryList.append(newCategory)
                        // If we retrieved all the categories, sort the list and reload data
                        if self.categoryList.count == categories.count {
                            self.categoryList.sort(by: { $0.getName() < $1.getName() })
                            self.collectionView.reloadData()
                        }
                    })
                }
            }
    }) { error in
        print(error.localizedDescription)
      }
}

    // MARK: - Get the image based on the path
    func getImage(path: String, completion: @escaping (UIImage) -> Void) {
        let image = storage.child(path)
        image.getData(maxSize: 1 * 100 * 100) { data, error in
            guard let data = data, let imageData = UIImage(data: data) else {
                print(error as Any)
                return
            }
            completion(imageData)
        }
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        let storyboard = UIStoryboard(name: "ProductsByCategory", bundle: nil)
        guard let productController = storyboard.instantiateViewController(withIdentifier: "ProductTableViewController") as? ProductTableViewController else {
            return
        }

        productController.setCategory(category: categoryList[indexPath.row].getName())
        let navigationController = self.navigationController
        navigationController?.setViewControllers([productController], animated: true)
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdenntifier = "CategoryCollectionViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdenntifier, for: indexPath) as! CategoryCollectionViewCell
        cell.configure(with: categoryList[indexPath.row].getImage(), text: categoryList[indexPath.row].getName())

        return cell
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width / 3, height: 150)
    }
}
