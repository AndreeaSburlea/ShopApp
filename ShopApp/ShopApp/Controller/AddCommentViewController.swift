//
//  AddCommentViewController.swift
//  ShopApp
//
//  Created by Viviana Mesaros on 17.06.2022.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import Photos
import PhotosUI
import Cosmos

class AddCommentViewController: UIViewController {

    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var reviewView: UIView!
    @IBOutlet private var commentTextField: UITextField! {
        didSet {
            commentTextField.becomeFirstResponder()
        }
    }

    lazy var cosmosView: CosmosView = {
        var view = CosmosView()
        return view
    }()

    private var imageRoot = ""
    private var commentRoot = ""
    private var ratingRoot = ""
    private var images = [UIImage]()
    private var rootsImages = [String]()

    func setRoots(commentRoot: String, imageRoot: String, ratingRoot: String) {
        self.commentRoot = commentRoot
        self.imageRoot = imageRoot
        self.ratingRoot = ratingRoot
    }

    // MARK: - Configure colletion view
    func configureCollection() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 153, height: 136)
        self.collectionView.collectionViewLayout = layout
    }

    // MARK: - Get root for images based on number of comments from current user
    func getRootByNumberOfComments(completion: @escaping (String) -> ()) {
        Database.database().reference().child(commentRoot).observeSingleEvent(of: DataEventType.value, with: { snapshot in
            guard snapshot.hasChildren() else {
                completion(self.imageRoot + "0")
                return
            }

            completion(self.imageRoot + "\(Int(snapshot.childrenCount))")
        })
    }

    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        // Hiding keyboard when tap in any blanck areas
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        configureCollection()
        configureCosmosView()
    }

    func configureCosmosView() {
        self.cosmosView.settings.fillMode = .full
        self.cosmosView.backgroundColor = .white
        self.cosmosView.rating = 0
        self.reviewView.addSubview(cosmosView)
    }

    // MARK: - Save review
    func saveReview() {
        let rating = self.cosmosView.rating

        guard rating != 0.0 else { return }

        Database.database().reference().child("\(self.ratingRoot)").observeSingleEvent(of: DataEventType.value) { snapshot in
            guard let rate = snapshot.value as? [String: String] else {
                Database.database().reference().child("\(self.ratingRoot)").setValue(["users": "1", "rate": "\(rating)"])
                return
            }

            guard let numberOfUsers = rate["users"] else { return }
            guard let oldRating = rate["rate"]  else { return }

            let newRating = (((Double(oldRating) ?? 0) * (Double(numberOfUsers) ?? 0)) + rating ) / ((Double(numberOfUsers) ?? 0) + 1)

            Database.database().reference().child("\(self.ratingRoot)").setValue(["users": "\((Double(numberOfUsers) ?? 0) + 1)", "rate": "\(newRating)"])
        }
    }

    // MARK: - Cancel button action
    @IBAction private func cancelAction(sender: UIButton ) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Add image button action
    @IBAction private func addImage() {
        let photoSourceRequestController = UIAlertController(title: "",
                                                             message: "Choose your photo source",
                                                             preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .camera
                imagePicker.delegate = self
                self.present(imagePicker, animated: true, completion: nil)
            }
        })

        let photoLibraryAction = UIAlertAction(title: "Photo library",
                                               style: .default,
                                               handler: { _ in

            var config = PHPickerConfiguration(photoLibrary: .shared())
            config.selectionLimit = 10
            config.filter = .images

            let cv = PHPickerViewController(configuration: config)
            cv.delegate = self
            self.present(cv, animated: true)
        })

        photoSourceRequestController.addAction(cameraAction)
        photoSourceRequestController.addAction(photoLibraryAction)

        present(photoSourceRequestController, animated: true, completion: nil)
    }

    // MARK: - Save images function
    func saveImage(comment: String, completion: @escaping () -> Void) {
        // If there is no image
        guard !self.images.isEmpty else {
            self.rootsImages.append("null")
            completion()
            return
        }

        self.getRootByNumberOfComments { root in
            let storage = Storage.storage().reference().child(root)

            for i in 0...(self.images.count - 1) {
                guard let image = self.images[i].pngData() else { return }
                storage.child("\(i).png").putData(image, metadata: nil) { _, error in

                    // Verify if there is an error
                    guard error == nil else {
                        self.rootsImages.append("null")
                        completion()
                        return
                    }

                    self.rootsImages.append("\(root)/\(i).png")

                    // Completion if get all the images root
                    if self.rootsImages.count == self.images.count {
                        completion()
                    }
                }
            }
        }
    }

    func saveAction() {
        if commentTextField.text == "" {
            let allFieldRequired = UIAlertController(title: "Oops",
                                                     message: "We can't proceed because the field is blank. Please note that field is required",
                                                     preferredStyle: .alert)
            allFieldRequired.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            present(allFieldRequired, animated: true, completion: nil)
        } else {
            let comment = commentTextField.text ?? ""
            self.saveImage(comment: comment) {
                Database.database().reference().child("\(self.commentRoot)/\(comment)").setValue(["rootsOfImages": self.rootsImages, "rate": ["\(self.cosmosView.rating)"]])
                self.saveReview()
            }
        }
    }
}

extension AddCommentViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let image = selectedImage.imageResized(to: CGSize(width: 100, height: 100))
            self.images.removeAll()
            self.images.append(image)
        }

        dismiss(animated: true, completion: nil)
    }
}

extension AddCommentViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        self.images.removeAll()

        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                guard let image = reading as? UIImage, error == nil else {
                    return
                }

                let imageResized = image.imageResized(to: CGSize(width: 100, height: 100))
                self.images.append(imageResized)

                if self.images.count == results.count {
                    self.collectionView.performSelector(onMainThread: #selector(UICollectionView.reloadData), with: nil, waitUntilDone: true)
                }
            }
        }
    }
}

extension AddCommentViewController: UICollectionViewDelegate, UICollectionViewDataSource {
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return self.images.count
     }

     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "commentImageCell", for: indexPath) as? CommentImageCollectionViewCell else {
             return UICollectionViewCell()
         }

         cell.configure(commentImage: self.images[indexPath.row])
         return cell
     }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let commentImagesViewController = self.storyboard?.instantiateViewController(withIdentifier: "CommentImagesViewController") as? CommentImagesViewController else { return }

        commentImagesViewController.setImages(images: self.images)
        present(commentImagesViewController, animated: true, completion: nil)
    }
 }

extension UIImage {
    func imageResized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
