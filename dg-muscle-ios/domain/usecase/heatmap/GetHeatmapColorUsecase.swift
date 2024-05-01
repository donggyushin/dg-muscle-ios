//
//  GetHeatmapColorUsecase.swift
//  dg-muscle-ios
//
//  Created by 신동규 on 5/1/24.
//

import Foundation

final class GetHeatmapColorUsecase {
    let historyRepository: HistoryRepository
    
    init(historyRepository: HistoryRepository) {
        self.historyRepository = historyRepository
    }
    
    func implement() -> HeatmapColorDomain {
        historyRepository.heatmapColor
    }
}
