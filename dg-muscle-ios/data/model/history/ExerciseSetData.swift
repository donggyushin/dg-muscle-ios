//
//  ExerciseSetData.swift
//  dg-muscle-ios
//
//  Created by 신동규 on 4/27/24.
//

import Foundation

struct ExerciseSetData: Codable {
    let id: String
    let weight: Double
    let reps: Int
    let unit: Unit
    
    init(from: ExerciseSetDomain) {
        id = from.id
        weight = from.weight
        reps = from.reps
        unit = .init(unit: from.unit)
    }
    
    var domain: ExerciseSetDomain {
        .init(id: id, unit: unit.domain, reps: reps, weight: weight)
    }
}

extension ExerciseSetData {
    enum Unit: String, Codable {
        case kg
        case lbs
        
        init(unit: ExerciseSetDomain.Unit) {
            switch unit {
            case .kg:
                self = .kg
            case .lbs:
                self = .lbs
            }
        }
        
        var domain: ExerciseSetDomain.Unit {
            switch self {
            case .kg:
                return .kg
            case .lbs:
                return .lbs
            }
        }
    }
}
