//
//  Navigations.swift
//  dg-muscle-ios
//
//  Created by 신동규 on 4/14/24.
//

import Foundation

struct MainNavigation: Identifiable, Hashable {
    
    enum Name: String {
        case setting
    }
    
    let name: Name
    var id: Int { name.hashValue }
}

struct ExerciseNavigation: Identifiable, Hashable, Equatable {
    static func == (lhs: ExerciseNavigation, rhs: ExerciseNavigation) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(id)
    }
    
    enum Name: String {
        case manage
        case step1
        case step2
    }
    
    let name: Name
    var id: Int { name.hashValue }
    var step2Depndency: Step2Dependency?
    
    struct Step2Dependency {
        let name: String
        let parts: [Exercise.Part]
    }
}
