//
//  HistoryRepositoryV2Impl.swift
//  dg-muscle-ios
//
//  Created by 신동규 on 4/13/24.
//

import Combine

final class HistoryRepositoryV2Impl: HistoryRepositoryV2 {
    static let shared = HistoryRepositoryV2Impl()
    
    var histories: [ExerciseHistory] {
        _histories
    }
    
    var historiesPublisher: AnyPublisher<[ExerciseHistory], Never> {
        $_histories.eraseToAnyPublisher()
    }
    
    @Published private var _histories: [ExerciseHistory] = []
    
    private init() {
        _histories = getExerciseHistoryFromFile()
        
        Task {
            _histories = try await get(lastId: nil, limit: 365)
        }
    }
    
    private func getExerciseHistoryFromFile() -> [ExerciseHistory] {
        (try? FileManagerHelper.load([ExerciseHistory].self, fromFile: .history)) ?? []
    }
    
    private func get(lastId: String?, limit: Int) async throws -> [ExerciseHistory] {
        var url = "https://exercisehistory-gethistories-kpjvgnqz6a-uc.a.run.app?limit=\(limit)"
        
        if let lastId {
            url = url + "&lastId=\(lastId)"
        }
        
        let histories: [ExerciseHistory] = try await APIClient.shared.request(url: url)
        
        try? FileManagerHelper.save(histories, toFile: .history)
        
        return histories
    }
}