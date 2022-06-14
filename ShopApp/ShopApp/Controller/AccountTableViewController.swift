//
//  AccountTableViewController.swift
//  ShopApp
//
//  Created by Andreea Sburlea on 10.06.2022.
//

import UIKit
import FirebaseAuth

class AccountTableViewController: UITableViewController {
    // swiftlint:disable line_length
    // swiftlint:disable implicitly_unwrapped_optional

    @IBAction private func close(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }

    lazy var dataSource = configureDataSource()

    enum Section {
        case general
        case client
    }

    struct LinkItem: Hashable {
        var text: String
        var image: String
        var detailText: String
        var detailImage: String
    }

    var sectionContent = [[LinkItem(text: "Settings", image: "gear", detailText: "Set your country preferences and notifications here", detailImage: "settings"),
                           LinkItem(text: "Pay methods", image: "creditcard.fill", detailText: "Here you can set your payment method", detailImage: "card"),
                           LinkItem(text: "Store locator", image: "location.circle.fill", detailText: "", detailImage: ""),
                           LinkItem(text: "Help", image: "questionmark.circle.fill", detailText: "Do you have any questions?", detailImage: "help"),
                           LinkItem(text: "Contact us", image: "phone.down.circle.fill", detailText: "You can contact us at: \n phone: 000 999 8887 \n email: shopapp@gmail.com", detailImage: "call")],
                          [LinkItem(text: "Personal Data", image: "person.text.rectangle.fill", detailText: "Here you can find your personal information", detailImage: "personal_data"),
                           LinkItem(text: "Log out", image: "person.circle.fill", detailText: "", detailImage: "" )]]

    var tappedContent: LinkItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Load table data
        tableView.dataSource = dataSource
        updateSnapshot()
        navigationItem.backButtonTitle = ""
    }

    // MARK: - Table view data source
    func configureDataSource() -> UITableViewDiffableDataSource<Section, LinkItem> {
        let cellIdentifier = "accountCell"
        let dataSource = UITableViewDiffableDataSource<Section, LinkItem>(tableView: tableView) { tableView, indexPath, linkItem -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            cell.textLabel?.text = linkItem.text

            cell.imageView?.image = UIImage(systemName: linkItem.image)
            return cell
        }

        return dataSource
    }

    func updateSnapshot() {
        // Create a snapshot and populate the data
        var snapshot = NSDiffableDataSourceSnapshot<Section, LinkItem>()
        snapshot.appendSections([.general, .client])
        snapshot.appendItems(sectionContent[0], toSection: .general)
        snapshot.appendItems(sectionContent[1], toSection: .client)

        dataSource.apply(snapshot, animatingDifferences: false)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tappedContent = sectionContent[indexPath.section][indexPath.row]
        switch(indexPath.section, indexPath.row) {
        case (0, 2):
            performSegue(withIdentifier: "showMap", sender: self)
        case (1, 1):
            logout()
        default:
            performSegue(withIdentifier: "showView", sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }

    func logout() {
        // Sign out from Google account
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }

        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(identifier: "LoginViewController")
        let navigationController = self.navigationController
        navigationController?.setViewControllers([loginViewController], animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showView" {
            let vc = segue.destination as? DetailViewController
            vc?.textString = tappedContent.detailText
            vc?.imageString = tappedContent.detailImage
        }
    }
}
