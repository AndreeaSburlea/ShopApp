//
//  CartOrderViewController.swift
//  ShopApp
//
//  Created by Andreea Sburlea on 13.07.2022.
//

import UIKit

class CartOrderViewController: UIViewController {

    @IBOutlet private var segmentedControl: UISegmentedControl!
    @IBOutlet private var orderContainer: UIView!
    @IBOutlet private var cartContainer: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        orderContainer.isHidden = false
        cartContainer.isHidden = true

        let storyboard = UIStoryboard(name: "Cart", bundle: nil)
        let cartController = storyboard.instantiateViewController(withIdentifier: "CartController")
        let orderController = storyboard.instantiateViewController(withIdentifier: "OrderController")
    }

    @IBAction private func indexChanged(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            orderContainer.isHidden = false
            cartContainer.isHidden = true
            self.title = "Cart"
        case 1:
            orderContainer.isHidden = true
            cartContainer.isHidden = false
            self.title = "Orders"
        default:
            break;
            }
    }
}
