//
//  ContentViewV2.swift
//  dg-muscle-ios
//
//  Created by 신동규 on 4/13/24.
//

import SwiftUI

struct ContentViewV2: View {
    
    @State var paths = NavigationPath()
    
    let historyViewModel: HistoryViewModel
    let exerciseRepository: ExerciseRepositoryV2
    let healthRepository: HealthRepository
    let userRepository: UserRepositoryV2
    let historyRepository: HistoryRepositoryV2
    
    var body: some View {
        ZStack {
            NavigationStack(path: $paths) {
                HistoryView(viewModel: historyViewModel,
                            paths: $paths,
                            exerciseRepository: exerciseRepository,
                            healthRepository: healthRepository)
                .navigationDestination(for: MainNavigation.self) { navigation in
                    switch navigation.name {
                    case .setting:
                        SettingV2View(viewModel: SettingV2ViewModel(userRepository: userRepository),
                                      paths: $paths)
                    }
                }
                .navigationDestination(for: HistoryNavigation.self, destination: { navigation in
                    switch navigation.name {
                    case .historyForm:
                        HistoryFormV2View(viewModel: .init(history:
                                                            navigation.historyForForm ??
                                                           ExerciseHistory(id: UUID().uuidString,
                                                                           date: todayDateString(),
                                                                           memo: nil,
                                                                           records: [],
                                                                           createdAt: nil),
                                                           paths: $paths,
                                                           historyRepository: historyRepository), 
                                          paths: $paths,
                                          exerciseRepository: exerciseRepository)
                    case .recordForm:
                        if let record = navigation.recordForForm, let date = navigation.dateForRecordForm {
                            RecordFormV2View(viewModel: .init(record: record,
                                                              exerciseRepository: exerciseRepository, 
                                                              historyRepository: historyRepository, 
                                                              date: date))
                        }
                    }
                })
                .navigationDestination(for: ExerciseNavigation.self) { navigation in
                    switch navigation.name {
                    case .manage:
                        ManageExerciseView(viewModel: .init(exerciseRepository: exerciseRepository),
                                           paths: $paths)
                    case .edit:
                        if let exercise = navigation.editExercise {
                            EditExerciseView(viewModel: .init(exercise: exercise,
                                                              exerciseRepository: exerciseRepository,
                                                              completeAction: {
                                paths.removeLast()
                            }))
                        }
                    case .step1:
                        ExerciseFormStep1View(viewModel: .init(),
                                              paths: $paths,
                                              exerciseRepository: exerciseRepository)
                    case .step2:
                        if let dependency = navigation.step2Depndency {
                            ExerciseFormStep2View(viewModel: .init(name: dependency.name,
                                                                   parts: dependency.parts,
                                                                   exerciseRepository: exerciseRepository,
                                                                   completeAction: {
                                paths.removeLast(2)
                            }))
                        }
                    }
                }
            }
        }
    }
    
    private func todayDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyMMdd"
        return dateFormatter.string(from: Date())
    }
}

#Preview {
    
    let historyRepository = HistoryRepositoryV2Test()
    let healthRepository = HealthRepositoryTest()
    let userRepository = UserRepositoryV2Test()
    let exerciseRepository = ExerciseRepositoryV2Test()
    
    let historyViewModel = HistoryViewModel(historyRepository: historyRepository,
                                            healthRepository: healthRepository,
                                            userRepository: userRepository)
    
    return ContentViewV2(historyViewModel: historyViewModel,
                         exerciseRepository: exerciseRepository,
                         healthRepository: healthRepository, 
                         userRepository: userRepository, 
                         historyRepository: historyRepository)
        .preferredColorScheme(.dark)
}