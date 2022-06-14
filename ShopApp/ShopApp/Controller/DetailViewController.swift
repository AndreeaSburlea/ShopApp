//
//  DetailViewController.swift
//  ShopApp
//
//  Created by Andreea Sburlea on 10.06.2022.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!

    var textString = ""
    var imageString = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel.text = textString
        imageView.image = UIImage(named: imageString)
    }
}
