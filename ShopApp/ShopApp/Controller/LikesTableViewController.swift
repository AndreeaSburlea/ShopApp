//
//  LikesTableViewController.swift
//  ShopApp
//
//  Created by Viviana Mesaros on 24.06.2022.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class LikesTableViewController: UITableViewController {

    @IBOutlet private var emptyProducts: UIView!
    @IBOutlet private var collectionView: UICollectionView!

    private var likesProducts = [Product]()
    private var indicatorView = UIActivityIndicatorView(style: .medium)

    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        // Add an activity indicator
        indicatorView = self.activityIndicator(style: .medium, center: self.view.center)
        view.addSubview(indicatorView)
        indicatorView.startAnimating()

        self.getLikesProducts()

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.hidesBarsOnSwipe = true

        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width / 2.1, height: 440)
        self.collectionView.collectionViewLayout = layout
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // To hide when scoll
        navigationController?.hidesBarsOnSwipe = true

        // Title to be large (not just in the begining )
        navigationController?.navigationBar.prefersLargeTitles = true
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

    // MARK: - Get image for a specific product
    func getImages(root: String, complition: @escaping (UIImage) -> Void) {
        let storage = Storage.storage().reference()
        let image = storage.child(root)

        image.getData(maxSize: 1 * 512 * 512) { data, error in
            guard let data = data, let imageData = UIImage(data: data) else {
                print(error as Any)
                return
            }

            complition(imageData)
        }
    }

    // MARK: - Get likes products from database
    func getLikesProducts() {
        guard let email = Auth.auth().currentUser?.email as? String else { return }
        let emailRef = email.replacingOccurrences(of: ".", with: " ")

        let ref = Database.database().reference().child("users/\(emailRef)/favourites").observe(DataEventType.value, with: { snapshot in

            guard let data = snapshot.value as? [String: String] else {
                self.indicatorView.stopAnimating()
                self.collectionView.backgroundView = self.emptyProducts
                self.collectionView.backgroundView?.isHidden = false
                print("not valid data")
                return
            }

            var products  = [Product]()
            // For every product in products table
            for dataKeys in data.keys {
                self.getImages(root: "images/\(dataKeys)/\(dataKeys)1.jpeg") { image in
                    var product = Product()
                    product.setName(name: dataKeys)
                    product.setImages(images: [image])
                    products.append(product)

                    if(products.count == data.keys.count) {
                        self.update(products: products)
                    }
                }
            }
        })
    }

    func update(products: [Product]) {
       // self.likesProducts.removeAll()
        self.likesProducts = products
        self.indicatorView.stopAnimating()
        self.collectionView.backgroundView?.isHidden = true
        self.collectionView.reloadData()
    }
}

extension LikesTableViewController: UICollectionViewDelegate, UICollectionViewDataSource {
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return self.likesProducts.count
     }

     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "likecell", for: indexPath) as? LikeCollectionViewCell else {
             return UICollectionViewCell()
         }

         cell.configure(nameProduct: self.likesProducts[indexPath.row].getName(), imageProduct: self.likesProducts[indexPath.row].getImages()[0])
         return cell
     }
 }
