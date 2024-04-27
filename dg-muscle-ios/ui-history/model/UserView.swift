//
//  UserView.swift
//  dg-muscle-ios
//
//  Created by 신동규 on 4/28/24.
//

import Foundation

struct UserView {
    let uid: String
    var displayName: String?
    var photoURL: URL?
    
    init(from: UserDomain) {
        uid = from.uid
        displayName = from.displayName
        photoURL = from.photoURL
    }
    
    var domain: UserDomain {
        .init(uid: uid, displayName: displayName, photoURL: photoURL)
    }
}
