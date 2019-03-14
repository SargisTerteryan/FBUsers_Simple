//
//  UserModel.swift
//  FBUsers
//
//  Created by Saqo on 1/26/19.
//  Copyright © 2019 Arcsinus. All rights reserved.
//

import UIKit
import Firebase

struct UserModel {
    
    // Global Constants
    static let NameKey = "name"
    static let ProfileImageKey = "profileImage"
    static let UIDKey = "uid"
    static let SubscriptionsKey = "subscriptions"
    
    // State
    let ref: DatabaseReference?
    let uid: String
    let fullName: String
    let imageUrl: String
    let subscriptions:  [String]?

    
    init(authData: Firebase.User) {
        self.ref = nil
        self.subscriptions = nil
        self.uid = authData.uid
        self.fullName = authData.displayName!
        self.imageUrl = authData.photoURL!.absoluteString
    }
    
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let name = value[UserModel.NameKey] as? String,
            let imageUrl = value[UserModel.ProfileImageKey] as? String,
            let uid = value[UserModel.UIDKey] as? String else {
                return nil
        }
        
        let subscriptions = value[UserModel.SubscriptionsKey] as? [String]

        self.ref = snapshot.ref
        self.fullName = name
        self.imageUrl = imageUrl
        self.uid = uid
        self.subscriptions = subscriptions
    }
    
    public func toAnyObject() -> Any {
        return [
            UserModel.UIDKey: uid,
            UserModel.NameKey: fullName,
            UserModel.ProfileImageKey: imageUrl,
        ]
    }
}
