//
//  Record.swift
//  dg-muscle-ios
//
//  Created by 신동규 on 2023/09/30.
//

struct Record: Codable {
    let exerciseId: String
    let sets: [ExerciseSet]
}
