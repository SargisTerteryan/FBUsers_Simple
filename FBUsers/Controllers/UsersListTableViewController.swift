//
//  UsersListTableViewController.swift
//  FBUsers
//
//  Created by Saqo on 1/26/19.
//  Copyright © 2019 Arcsinus. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class UsersListTableViewController: UITableViewController {
    
    struct Constants {
        static let UsersPath = "users"
        static let SignOutIconName = "sign_out"
        static let UserCellIdentifier = "userCell"
        static let FollowText = "Follow"
        static let UnFollowText = "UnFollow"
        static let SpinnerSize = 20
        static let NoDataViewHeight: CGFloat = 44.0
    }
    
    @IBOutlet weak var noDataView: UIView!
    private let usersRef = Database.database().reference(withPath: Constants.UsersPath)
    private var currentUser: Firebase.User! = Auth.auth().currentUser
    private var currentUserSubscriptions: Set<String> = []
    private var usersList: [UserModel]! = []
    
    private let loadingView = UIView()
    private let spinner = UIActivityIndicatorView()
   
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsMultipleSelectionDuringEditing = false
        tableView.tableFooterView = UIView()

        prepareNavigationBar()
        configureUsersList()
    }
    
    // MARK: - Data Configuration
    
    private func configureUsersList() {
        setLoadingOnScreen()
        usersRef.queryOrdered(byChild: UserModel.NameKey).observe(.value, with: { [weak self] snapshot in
            guard let unwrappedSelf = self else { return }

            var userItems: [UserModel] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                    let userItem = UserModel(snapshot: snapshot) {
                    if (unwrappedSelf.isLogedInUser(userUID: userItem.uid)) {
                        unwrappedSelf.configureSubscriptions(userSubscriptions: userItem.subscriptions)
                    } else {
                        userItems.append(userItem)
                    }
                }
            }
            unwrappedSelf.usersList = userItems
            unwrappedSelf.prepareNoDataView()
            unwrappedSelf.tableView.reloadData()
            unwrappedSelf.removeLoading()
        })
    }

    private func configureSubscriptions(userSubscriptions: [String]?) {
        if let subscriptions = userSubscriptions {
            self.currentUserSubscriptions = Set(subscriptions)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userCell = tableView.dequeueReusableCell(withIdentifier: Constants.UserCellIdentifier, for: indexPath) as! UserTableViewCell

        let model = usersList[indexPath.row]
        userCell.configureUserCell(user: model)

        return userCell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let model = usersList[editActionsForRowAt.row]
        let subscriptionRef = self.usersRef.child(currentUser.uid).child(UserModel.SubscriptionsKey)

        let isFolowedByUser = isFolowed(selectedUserUID: model.uid)
        let title = isFolowedByUser ? Constants.UnFollowText : Constants.FollowText
        
        let rowActionButton = UITableViewRowAction(style: .normal, title: title) { action, index in
            if isFolowedByUser {
                self.currentUserSubscriptions.remove(model.uid)
            } else {
                self.currentUserSubscriptions.insert(model.uid)
            }
            
            subscriptionRef.setValue(Array(self.currentUserSubscriptions))
        }
        
        rowActionButton.backgroundColor = isFolowedByUser ? .red : .blue
    
        return [rowActionButton]
    }
    
    // MARK: - Actions

    @objc private func signOut() {
        Helper.signOutAlert(controller: self) {
            do {
                try Auth.auth().signOut()
                self.dismiss(animated: true, completion: nil)
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Helpers

    private func isFolowed(selectedUserUID: String) -> Bool {
        if self.currentUserSubscriptions.contains(selectedUserUID) {
            return true
        }
        return false
    }
    
    private func isLogedInUser(userUID: String) -> Bool {
        return userUID == currentUser.uid
    }
    
    private func prepareNoDataView() {
        if usersList.count > 0 {
            noDataView.frame.size.height = 0
            noDataView.isHidden = true
        } else {
            noDataView.frame.size.height = Constants.NoDataViewHeight
            noDataView.isHidden = false
        }
    }
    
    // MARK: - View Methods
    
    private func prepareNavigationBar() {
        let signOutIcon = UIImage(named: Constants.SignOutIconName)
        let logOutButton = UIBarButtonItem(image: signOutIcon,
                                           style: .plain,
                                           target: self,
                                           action: #selector(signOut))
        
        logOutButton.tintColor = .red
        navigationItem.rightBarButtonItem = logOutButton
        title = currentUser.displayName
    }
    
    private func setLoadingOnScreen() {
        loadingView.center = tableView.center
        spinner.activityIndicatorViewStyle = .gray
        spinner.frame = CGRect(x: 0, y: 0, width: Constants.SpinnerSize, height: Constants.SpinnerSize)
        spinner.startAnimating()
        loadingView.addSubview(spinner)
        tableView.addSubview(loadingView)
    }
    
    private func removeLoading() {
        spinner.stopAnimating()
        spinner.isHidden = true
    }

}
