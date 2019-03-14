//
//  Helper.swift
//  FBUsers
//
//  Created by Saqo on 1/26/19.
//  Copyright © 2019 Arcsinus. All rights reserved.
//

import UIKit

class Helper {
    
    static let StoryboardName = "Main"
    static let SignOutText = "Sign Out"
    static let SignOutMessage = "Are you sure you want to sign out?"
    static let CancelText = "Cancel"
    static let ErrorText = "Error"
    static let OKText = "OK"
    
    static func instantiateFromStoryboard(identifier: String) -> UIViewController {
        let storyboard = UIStoryboard(name: StoryboardName, bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }

    static func showErrorAllert(controller: UIViewController, errorMessage: String) -> Void {
        let alert = UIAlertController(title: ErrorText, message: errorMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: OKText, style: UIAlertAction.Style.default, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }
    
    static func signOutAlert(controller: UIViewController, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: SignOutMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: CancelText, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: SignOutText, style: .destructive, handler: { _ in
            completion()
        }))
        
        controller.present(alert, animated: true, completion: nil)
    }
    
}
