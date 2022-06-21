 //
 //  ProductImagesPageViewController.swift
 //  ShopApp
 //
 //  Created by Viviana Mesaros on 06.06.2022.
 //

import UIKit
import FirebaseStorage

 protocol ProductImagesPageViewControllerDelegate: AnyObject {
     func didUpdatePageIndex(currentIndex: Int)
 }

 class ProductImagesPageViewController: UIPageViewController {

     weak var walkthroughDelegate: ProductImagesPageViewControllerDelegate?

     private var product = Product()
     private var currentIndex = 0

     override func viewDidLoad() {
         super.viewDidLoad()

         self.getImages()

         // Create the first walkthrough screen
         if let startingViewController = contentViewController(at: 0) {
             setViewControllers([startingViewController], direction: .forward, animated: true, completion: nil)
         }
     }

     func getCurrentIndex() -> Int { return self.currentIndex }
     func setProduct(product: Product) { self.product = product }

     // MARK: - Get the rest of the images
     func getImages() {
         var imagesArray = [UIImage]()
         let storage = Storage.storage().reference()
         var rootImage = "images/\(product.getName())/\(product.getName())"

         for i in 1...4 {
             let root = rootImage + "\(i).jpeg"

             let image = storage.child(root)

             image.getData(maxSize: 1 * 512 * 512) { data, error in
                 guard let data = data, let imageData = UIImage(data: data) else {
                     print(error as Any)
                     return
                 }

                 imagesArray.append(imageData)

                 if imagesArray.count == 4 {
                     print("FINISH")
                     self.product.setImages(images: imagesArray)
                     self.dataSource = self
                     self.delegate = self
                 }
             }
         }
     }
 }

 extension ProductImagesPageViewController: UIPageViewControllerDataSource {
     func pageViewController(_ pageViewController: UIPageViewController,
                             viewControllerBefore viewController: UIViewController) -> UIViewController? {
         guard var index = (viewController as? ProductImagesContainerViewController)?.getIndex() else {
             return UIViewController()
         }

         index -= 1
         return contentViewController(at: index)
     }

     func pageViewController(_ pageViewController: UIPageViewController,
                             viewControllerAfter viewController: UIViewController) -> UIViewController? {
         guard var index = (viewController as? ProductImagesContainerViewController)?.getIndex() else {
             return UIViewController()
         }

         index += 1
         return contentViewController(at: index)
     }

     func contentViewController(at index: Int) -> ProductImagesContainerViewController? {
         if index < 0 || index > 3 {
             return nil
         }

         // Create a new view controller and pass suitable data.
         let storyboard = UIStoryboard(name: "ProductsByCategory", bundle: nil)
         if let pageContentViewController = storyboard.instantiateViewController(withIdentifier: "ImagesProductViewController") as? ProductImagesContainerViewController {
             pageContentViewController.configure(index: index, image: product.getImages()[index])
             return pageContentViewController
         }

         return nil
     }
 }

 extension ProductImagesPageViewController: UIPageViewControllerDelegate {
     // The method will be automatically called after a gesture-driven transition completes
     func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool,
                             previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
         if completed {
             if let contentViewController = pageViewController.viewControllers?.first as? ProductImagesContainerViewController {
                 currentIndex = contentViewController.getIndex()
                 walkthroughDelegate?.didUpdatePageIndex(currentIndex: contentViewController.getIndex())
             }
         }
     }
 }
