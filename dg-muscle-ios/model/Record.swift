//
//  Record.swift
//  dg-muscle-ios
//
//  Created by 신동규 on 2023/09/30.
//

import Foundation

struct Record: Codable, Equatable, Identifiable, Hashable {
    var id: String? = UUID().uuidString
    let exerciseId: String
    let sets: [ExerciseSet]
    
    var volume: Double {
        sets.reduce(0, { $0 + $1.volume })
    }
    
    var parts: [Exercise.Part] {
        store.exercise.exercises.first(where: { $0.id == exerciseId })?.parts ?? []
    }
}
