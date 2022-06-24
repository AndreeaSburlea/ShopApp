//
//  PersonalDataViewController.swift
//  ShopApp
//
//  Created by Andreea Sburlea on 23.06.2022.
//

import UIKit
import FirebaseAuth
import Firebase

class PersonalDataViewController: UIViewController {

    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var emailLabel: UILabel!
    @IBOutlet private var photoImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setPhotoProperties()
        getUserInfo()
    }

    func setPhotoProperties() {
        // Set photoImageView properties
        photoImageView.layer.borderWidth = 1.0
        photoImageView.layer.masksToBounds = false
        photoImageView.layer.borderColor = UIColor.white.cgColor
        photoImageView.layer.cornerRadius = photoImageView.frame.size.width / 2
        photoImageView.clipsToBounds = true
    }

    func getUserInfo() {
        guard let emailAddress = Auth.auth().currentUser?.email as? String else { return }
        guard let name = Auth.auth().currentUser?.displayName as? String else { return }
        guard let imageUrl = Auth.auth().currentUser?.photoURL as? URL else { return }

        downloadImage(from: imageUrl)
        emailLabel.text = emailAddress
        nameLabel.text = name
    }

    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

    func downloadImage(from url: URL) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            // always update the UI from the main thread
            DispatchQueue.main.async() { [weak self] in
                self?.photoImageView.image = UIImage(data: data)
            }
        }
    }
}
