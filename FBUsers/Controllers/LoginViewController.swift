//
//  ViewController.swift
//  FBUsers
//
//  Created by Saqo on 1/26/19.
//  Copyright © 2019 Arcsinus. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var imaged: UIImageView!
    struct Constants {
        static let UsersListSegueIdentifier = "usersList"
        static let UsersDBPath = "users"
        static let FBPermissions = ["public_profile", "email"]
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
//        imaged.image?.renderingMode = .alwaysTemplate
//        imaged.tintColor = .white
        Auth.auth().addStateDidChangeListener() { [weak self] auth, user in
            if user != nil {
                guard let unwrappedSelf = self else { return }
                unwrappedSelf.performSegue(withIdentifier: Constants.UsersListSegueIdentifier, sender: nil)
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func facebookLogin(_ sender: Any) {
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: Constants.FBPermissions, from: self) { [weak self] (result, error) in
            if let error = error {
                let errorMessage = "Failed to login: \(error.localizedDescription)"
                Helper.showErrorAllert(controller: LoginViewController.self(), errorMessage: errorMessage)
                return
            }
            guard let unwrappedSelf = self else { return }
            guard let accessToken = FBSDKAccessToken.current() else { return }

            unwrappedSelf.firebaseAuth(accessToken: accessToken)
        
        }
    }

    // MARK: - Firebase Auth Helper
    
    private func firebaseAuth(accessToken: FBSDKAccessToken) {
        let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
        
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                let errorMessage = "Failed to login: \(error.localizedDescription)"
                Helper.showErrorAllert(controller: self, errorMessage: errorMessage)
                return
            }

            let usersReference  = Database.database().reference().child(Constants.UsersDBPath)
            let userModel = UserModel(authData: authResult!.user)
            let currentUserReference = usersReference.child(userModel.uid)
            
            usersReference.observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChild(userModel.uid) {
                    currentUserReference.updateChildValues(userModel.toAnyObject() as! [AnyHashable : Any])
                } else {
                    currentUserReference.setValue(userModel.toAnyObject())
                }
            })
            
        }
    }

}

