//
//  OrderTableViewCell.swift
//  ShopApp
//
//  Created by Andreea Sburlea on 13.07.2022.
//

import UIKit

class OrderTableViewCell: UITableViewCell {

    @IBOutlet private var orderNumber: UILabel!
    @IBOutlet private var orderStatus: UILabel!
    @IBOutlet private var orderTotal: UILabel!
    @IBOutlet private var orderDetailProducts: UIButton!

    func configure(number: String, status: String, total: String) {
        self.orderNumber.text = number
        self.orderStatus.text = status
        self.orderTotal.text = total
    }
}
