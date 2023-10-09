//
//  ExerciseListView.swift
//  dg-muscle-ios
//
//  Created by 신동규 on 10/3/23.
//

import SwiftUI
import Combine

final class ExerciseListViewNotificationCenter: ObservableObject {
    static let shared = ExerciseListViewNotificationCenter()
    private init() { }
    
    @Published var exercise: Exercise?
}

protocol ExerciseListViewDependency {
    func tapAdd()
    func tapSave(exercises: [Exercise])
    func tap(exercise: Exercise)
}

struct ExerciseListView: View {
    let dependency: ExerciseListViewDependency
    @StateObject var notificationCenter = ExerciseListViewNotificationCenter.shared
    @State var exercises: [Exercise]
    @State var removalWarningTextVisible = false
    
    var body: some View {
        Form {
            Section {
                ForEach(exercises) { exercise in
                    Text(exercise.name)
                        .onTapGesture {
                            dependency.tap(exercise: exercise)
                        }
                }
                .onDelete { indexSet in
                    exercises.remove(atOffsets: indexSet)
                    withAnimation {
                        removalWarningTextVisible = true
                    }
                }
                .onMove { from, to in
                    exercises.move(fromOffsets: from, toOffset: to)
                }
                Button("Add", systemImage: "plus.app") {
                    dependency.tapAdd()
                }
            } header: {
                Text("exercises")
            } footer: {
                if removalWarningTextVisible {
                    Text("Be careful, removal exercises can affect your previous records")
                        .foregroundStyle(.red)
                        .italic()
                }
            }
            
            Button("Save") {
                let exercises = exercises.enumerated().map({ index, exercise in
                    var exercise = exercise
                    exercise.order = index
                    return exercise
                })
                dependency.tapSave(exercises: exercises)
            }
        }
        .onReceive(notificationCenter.$exercise) { value in
            guard let value else { return }
            var exercises = self.exercises
            
            if let index = exercises.firstIndex(of: value) {
                exercises[index] = value
            } else {
                exercises.append(value)
            }
            exercises = exercises.sorted(by: { $0.order < $1.order })
            self.exercises = []
            self.exercises = exercises
        }
    }
}
