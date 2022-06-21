//
//  ImagesProductViewController.swift
//  ShopApp
//
//  Created by Viviana Mesaros on 06.06.2022.
//

 import UIKit

 class ProductImagesContainerViewController: UIViewController {

     @IBOutlet private var contentImageView: UIImageView!
     private var image = UIImage()
     private var index = 0

     override func viewDidLoad() {
         super.viewDidLoad()

         contentImageView.image = image
     }

     func configure(index: Int, image: UIImage) {
         self.index = index
         self.image = image
     }

     func getIndex() -> Int { return self.index }
 }
