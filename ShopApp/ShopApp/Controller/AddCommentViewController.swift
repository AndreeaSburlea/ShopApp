//
//  AddCommentViewController.swift
//  ShopApp
//
//  Created by Viviana Mesaros on 17.06.2022.
//

import UIKit
import FirebaseDatabase

class AddCommentViewController: UIViewController {

    @IBOutlet private var commentTextField: UITextField! {
        didSet {
            commentTextField.becomeFirstResponder()
        }
    }

    private var root: String = ""

    func setRoot(root: String) { self.root = root }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Hiding keyboard when tap in any blanck areas
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

    }

    @IBAction private func cancelAction(sender: UIButton ) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func saveButtonTapped(sender: UIButton ) {
        if commentTextField.text == "" {
            let allFieldRequired = UIAlertController(title: "Oops",
                                                     message: "We can't proceed because the field is blank. Please note that field is required",
                                                     preferredStyle: .alert)
            allFieldRequired.addAction(UIAlertAction(title: String(localized: "Ok", comment: "Ok"), style: .cancel, handler: nil))
            present(allFieldRequired, animated: true, completion: nil)
        } else {
            Database.database().reference().child(root).setValue(commentTextField.text)

            dismiss(animated: true, completion: nil)
        }
    }
}
