//
//  ViewController.swift
//  ShopApp
//
//  Created by Andreea Sburlea on 25.05.2022.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

class LoginViewController: UIViewController {

    @IBOutlet private var signInButton: GIDSignInButton!

    @IBAction private func googleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            if error != nil {
                return
            }

            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            Auth.auth().signIn(with: credential) { _, error in
                if let error = error {
                    _ = error as NSError
                    print("Error")
                } else {
            // User is signed in
                    print("signed")
                    self.navigateToHomeScreen()
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if Auth.auth().currentUser != nil {
            print("SIGNED IN")
            navigateToHomeScreen()
        } else {
            print("LOGGED OUT")
        }
    }

    func navigateToHomeScreen() {
        let storyboard = UIStoryboard(name: "HomePage", bundle: nil)
        let homeViewController = storyboard.instantiateViewController(identifier: "HomeViewController")
        let navigationController = self.navigationController
        navigationController?.setViewControllers([homeViewController], animated: true)
    }
}
