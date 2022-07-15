//
//  OrderViewController.swift
//  ShopApp
//
//  Created by Andreea Sburlea on 13.07.2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class OrderViewController: UIViewController {
    // swiftlint:disable line_length
    // swiftlint:disable force_cast

    @IBOutlet private var orderTableView: UITableView!

    lazy var dataSource = configureDataSource()
    var orderProducts = [OrderProduct]()
    let ref = Database.database().reference()
    let cellIdentifier = "orderCell"

    enum Section {
        case all
    }

    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        getOrders {
            self.updateSnapshot()
        }
    }
    
    @IBAction private func getOrderDetails(_ sender: UIButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: self.orderTableView)
        guard let indexPath1 = self.orderTableView.indexPathForRow(at: buttonPosition) else { return }
        let storyboard = UIStoryboard(name: "Cart", bundle: nil)
        guard let orderController = storyboard.instantiateViewController(withIdentifier: "OrderDetailViewController") as? OrderDetailViewController else {
            return
        }
        orderController.setOrder(order: orderProducts[indexPath1.row].getNumber())
        show(orderController, sender: self)
    }

    func updateSnapshot() {
        // Create a snapshot and populate the data
        var snapshot = NSDiffableDataSourceSnapshot<Section, OrderProduct>()
        snapshot.appendSections([.all])
        snapshot.appendItems(orderProducts, toSection: .all)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    // MARK: - Get the orders from database
    func getOrders(completion: @escaping () -> Void) {
        guard let email = Auth.auth().currentUser?.email as? String else { return }
        ref.child("users/" + email.replacingOccurrences(of: ".", with: " ") + "/orders").observeSingleEvent(of: .value, with: { snapshot in

            // Get "Cart" from Firebase
            guard let orderValue = snapshot.value as? NSDictionary else { return }
            // Get the attributes for each cart product
            for key in orderValue.allKeys {
                var orderProduct = OrderProduct()
                orderProduct.setNumber(number: key as! String)
                if let propertyList = orderValue.value(forKey: key as! String) as? NSDictionary {
                    for property in propertyList {
                        switch property.key as! String {
                        case "status":
                            orderProduct.setStatus(status: property.value as! String)
                        case "total":
                            orderProduct.setTotal(total: property.value as! String)
                        default:
                            break
                        }
                    }
                    self.orderProducts.append(orderProduct)
                } else {
                    return
                }
            }
            self.orderProducts.sort(by: { $0.getTotal() < $1.getTotal() })
            completion()
        })
    }
}

extension OrderViewController: UITableViewDelegate {
    func configureDataSource() -> UITableViewDiffableDataSource<Section, OrderProduct> {
        let dataSource = UITableViewDiffableDataSource<Section, OrderProduct>(
            tableView: orderTableView,
            cellProvider: {  tableView, indexPath, orderProduct in
                let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as? OrderTableViewCell
                cell?.configure(number: orderProduct.getNumber(),
                                status: orderProduct.getStatus(),
                                total: orderProduct.getTotal())

                return cell
            }
        )

        return dataSource
    }
}
