//
//  OrderProduct.swift
//  ShopApp
//
//  Created by Andreea Sburlea on 13.07.2022.
//

import Foundation

struct OrderProduct: Hashable {
    private var number: String
    private var status: String
    private var total: String

    func getNumber() -> String { return self.number }
    func getStatus() -> String { return self.status }
    func getTotal() -> String { return self.total }

    mutating func setNumber(number: String) { self.number = number }
    mutating func setStatus(status: String) { self.status = status }
    mutating func setTotal(total: String) { self.total = total }

    init(number: String, status: String, total: String) {
        self.number = number
        self.status = status
        self.total = total
    }

    mutating func configure(number: String, status: String, total: String) {
        self.number = number
        self.status = status
        self.total = total
    }

    init() {
        self.init(number: "", status: "", total: "")
    }
}
