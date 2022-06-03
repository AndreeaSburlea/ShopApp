//
//  HomeViewController.swift
//  ShopApp
//
//  Created by Andreea Sburlea on 27.05.2022.
//

import UIKit
import FirebaseAuth

class HomeViewController: UIViewController {
    // swiftlint:disable line_length
    // swiftlint:disable force_cast

    var categoryList: [String] = ["coat", "jacket", "sweat", "tshirt", "shirt", "dress", "pants", "skirt"]

    @IBOutlet private var collectionView: UICollectionView!

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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let cellIdentifier = "CategoryCollectionViewCell"
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width / 3, height: 120)
        collectionView.collectionViewLayout = layout

        collectionView.register(CategoryCollectionViewCell.nib(), forCellWithReuseIdentifier: cellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        let storyboard = UIStoryboard(name: "ProductsByCategory", bundle: nil)
        guard let productController = storyboard.instantiateViewController(withIdentifier: "ProductTableViewController") as? ProductTableViewController else {
            return
        }

        productController.setCategory(category: categoryList[indexPath.row])
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
        cell.configure(with: UIImage(named: categoryList[indexPath.row])!, text: categoryList[indexPath.row])

        return cell
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width / 3, height: 150)
    }
}
