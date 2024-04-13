//
//  UserRepositoryV2Test.swift
//  dg-muscle-ios
//
//  Created by 신동규 on 4/13/24.
//

import Combine
import Foundation

final class UserRepositoryV2Test: UserRepositoryV2 {
    var user: DGUser? {
        _user
    }
    
    var userPublisher: AnyPublisher<DGUser?, Never> {
        $_user.eraseToAnyPublisher()
    }
    
    var isLogin: Bool {
        return user != nil
    }
    
    @Published private var _user: DGUser?
    
    init() {
        prepareMockData()
    }
    
    private func prepareMockData() {
        /// photo url https://firebasestorage.googleapis.com:443/v0/b/dg-muscle.appspot.com/o/profilePhoto%2FtaEJh30OpGVsR3FEFN2s67A8FvF3%2F3D91567D-E280-4861-B3B2-68E571150165.png?alt=media&token=35985183-c69b-4c6d-8e56-f1aba8daabd4
        _user = .init(uid: "uid", displayName: "DONG GYU", photoURL: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/dg-muscle.appspot.com/o/profilePhoto%2FtaEJh30OpGVsR3FEFN2s67A8FvF3%2F3D91567D-E280-4861-B3B2-68E571150165.png?alt=media&token=35985183-c69b-4c6d-8e56-f1aba8daabd4"))
    }
}
