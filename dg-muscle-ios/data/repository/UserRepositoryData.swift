//
//  UserRepositoryData.swift
//  dg-muscle-ios
//
//  Created by 신동규 on 4/27/24.
//

import Foundation
import Combine
import FirebaseAuth

final class UserRepositoryData: UserRepository {
    static let shared = UserRepositoryData()
    
    var user: UserDomain? { _user }
    var userPublisher: AnyPublisher<UserDomain?, Never> { $_user.eraseToAnyPublisher() }
    @Published private var _user: UserDomain?
    
    var isLogin: Bool { _isLogin }
    var isLoginPublisher: AnyPublisher<Bool, Never> { $_isLogin.eraseToAnyPublisher() }
    @Published private var _isLogin: Bool = true
    
    var users: [UserDomain] { _users }
    var usersPublisher: AnyPublisher<[UserDomain], Never> { $_users.eraseToAnyPublisher() }
    @Published private var _users: [UserDomain] = []
    
    private var cancellables = Set<AnyCancellable>()
    private init() {
        bind()
    }
    
    func signOut() throws {
        try Authenticator().signOut()
    }
    
    func updateUser(displayName: String?, photoURL: URL?) async throws {
        _user?.displayName = displayName
        _user?.photoURL = photoURL
        try await Authenticator().updateUser(displayName: displayName, photoURL: photoURL)
    }
    
    func updateUser(displayName: String?) async throws {
        _user?.displayName = displayName
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = displayName
        try await changeRequest?.commitChanges()
    }
    
    func updateUser(photoURL: URL?) async throws {
        _user?.photoURL = photoURL
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.photoURL = photoURL
        try await changeRequest?.commitChanges()
    }
    
    func withDrawal() async -> (any Error)? {
        await Authenticator().withDrawal()
    }
    
    private func postProfile(id: String, displayName: String?, photoURL: String?) async throws {
        let url = FunctionsURL.user(.postprofile)
        struct Body: Codable {
            let id: String
            let displayName: String
            let photoURL: String?
        }
        let body: Body = .init(id: id, displayName: displayName ?? "", photoURL: photoURL)
        let _: ResponseData = try await APIClient.shared.request(method: .post, url: url, body: body)
    }
    
    private func getUsers() async throws -> [UserDomain] {
        let users: [UserData] = try await APIClient.shared.request(url: FunctionsURL.user(.getprofiles))
        return users.map { $0.domain }
    }
    
    private func bind() {
        $_user
            .compactMap({ $0 })
            .sink { user in
                Task {
                    try await self.postProfile(id: user.uid, displayName: user.displayName, photoURL: user.photoURL?.absoluteString)
                }
            }
            .store(in: &cancellables)
        
        Auth.auth().addStateDidChangeListener { _, user in
            guard let user else {
                self._user = nil
                self._isLogin = false
                return
            }
            self._user = .init(uid: user.uid, displayName: user.displayName, photoURL: user.photoURL)
            self._isLogin = true
        }
    }
}