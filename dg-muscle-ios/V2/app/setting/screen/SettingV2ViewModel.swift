//
//  SettingV2ViewModel.swift
//  dg-muscle-ios
//
//  Created by 신동규 on 4/13/24.
//

import Foundation
import Combine

final class SettingV2ViewModel: ObservableObject {
    @Published private(set) var user: DGUser?
    
    private let userRepository: UserRepositoryV2
    
    private var cancellables = Set<AnyCancellable>()
    
    init(userRepository: UserRepositoryV2) {
        self.userRepository = userRepository
        bind()
    }
    
    private func bind() {
        userRepository.userPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.user = user
            }
            .store(in: &cancellables)
    }
}