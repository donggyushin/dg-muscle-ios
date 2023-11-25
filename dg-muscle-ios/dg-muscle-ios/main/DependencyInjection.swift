//
//  DependencyInjection.swift
//  dg-muscle-ios
//
//  Created by 신동규 on 2023/09/28.
//

import SwiftUI
import Foundation

final class DependencyInjection {
    static let shared = DependencyInjection()
    
    private init () { }
    
    func setting(
        paths: Binding<[ContentView.NavigationPath]>,
        isPresentedWithDrawalConfirm: Binding<Bool>
    ) -> SettingViewDependency {
        SettingViewDependencyImpl(paths: paths, isPresentedWithDrawalConfirm: isPresentedWithDrawalConfirm)
    }
    
    func bodyProfile(paths: Binding<[ContentView.NavigationPath]>,
                     isShowingProfilePhotoPicker: Binding<Bool>,
                     showingErrorState: Binding<ContentView.ShowingErrorState>
    ) -> BodyProfileViewDependency {
        return BodyProfileViewDependencyImpl(paths: paths,
                                             isShowingProfilePhotoPicker: isShowingProfilePhotoPicker,
                                             showingErrorState: showingErrorState)
    }
    
    func profilePhotoPicker(loadingState: Binding<ContentView.LoadingState>,
                            showingSuccessState: Binding<ContentView.ShowingSuccessState>,
                            showingErrorState: Binding<ContentView.ShowingErrorState>) -> PhotoPickerViewDependency {
        ProfilePhotoPickerDependencyImpl(loadingState: loadingState,
                                         showingErrorState: showingErrorState,
                                         showingSuccessState: showingSuccessState)
    }
    
    func withdrawalConfirm(showingErrorState: Binding<ContentView.ShowingErrorState>) -> WithdrawalConfirmDependency {
        WithdrawalConfirmDependencyImpl(showingErrorState: showingErrorState)
    }
    
    func exerciseDiary(paths: Binding<[ContentView.NavigationPath]>, monthlyChartViewIngredient: Binding<ContentView.MonthlyChartViewIngredient>) -> ExerciseDiaryDependency {
        ExerciseDiaryDependencyImpl(paths: paths, monthlyChartViewIngredient: monthlyChartViewIngredient)
    }
    
    func historyForm(showingErrorState: Binding<ContentView.ShowingErrorState>, paths: Binding<[ContentView.NavigationPath]>) -> HistoryFormDependency {
        return HistoryFormDependencyImpl(showingErrorState: showingErrorState, paths: paths)
    }
    
    func recordForm(paths: Binding<[ContentView.NavigationPath]>) -> RecordFormDependency {
        RecordFormDependencyImpl(paths: paths)
    }
    
    func exerciseForm(paths: Binding<[ContentView.NavigationPath]>) -> ExerciseFormDependency {
        ExerciseFormDependencyImpl(paths: paths)
    }
    
    func setForm(paths: Binding<[ContentView.NavigationPath]>) -> SetFormViewDependency {
        SetFormViewDependencyImpl(paths: paths)
    }
    
    func exerciseList(
        paths: Binding<[ContentView.NavigationPath]>,
        showingErrorState: Binding<ContentView.ShowingErrorState>
    ) -> ExerciseListViewDependency {
        ExerciseListViewDependencyImpl(paths: paths,
                                       showingErrorState: showingErrorState)
    }
    
    func selectExercise(paths: Binding<[ContentView.NavigationPath]>) -> SelectExerciseDependency {
        SelectExerciseDependencyImpl(paths: paths)
    }
    
    func exerciseInfoContainer(loadingState: Binding<ContentView.LoadingState>,
                               showingErrorState: Binding<ContentView.ShowingErrorState>,
                               showingSuccessState: Binding<ContentView.ShowingSuccessState>
    ) -> ExerciseInfoContainerDependency {
        ExerciseInfoContainerDependencyImpl(loadingState: loadingState,
                                            showingErrorState: showingErrorState,
                                            showingSuccessState: showingSuccessState)
    }
}

struct SelectExerciseDependencyImpl: SelectExerciseDependency {
    
    @Binding var paths: [ContentView.NavigationPath]
    
    func select(exercise: Exercise) {
        let _ = paths.popLast()
        RecordFormNotificationCenter.shared.exercise = exercise
    }
}

struct ExerciseListViewDependencyImpl: ExerciseListViewDependency {
    
    @Binding var paths: [ContentView.NavigationPath]
    @Binding var showingErrorState: ContentView.ShowingErrorState
    
    func tapAdd() {
        paths.append(.exerciseForm(nil, nil, "", [], false))
    }
    
    func tapSave(exercises: [Exercise]) {
        Task {
            let _ = paths.popLast()
            store.exercise.set(exercises: exercises)
            let response = try await ExerciseRepository.shared.set(exercises: exercises)
            store.exercise.updateExercises()
            
            if let errorMessage = response.message {
                withAnimation {
                    showingErrorState = .init(showing: true, message: errorMessage)
                }
            }
        }
    }
    
    func tap(exercise: Exercise) {
        paths.append(.exerciseForm(exercise.id, exercise.order, exercise.name, exercise.parts, exercise.favorite))
    }
}

struct SetFormViewDependencyImpl: SetFormViewDependency {
    
    @Binding var paths: [ContentView.NavigationPath]
    
    func save(data: ExerciseSet) {
        let _ = paths.popLast()
        RecordFormNotificationCenter.shared.set = data
    }
}

struct ExerciseFormDependencyImpl: ExerciseFormDependency {
    
    @Binding var paths: [ContentView.NavigationPath]
    
    func tapSave(data: Exercise) {
        let _ = paths.popLast()
        ExerciseListViewNotificationCenter.shared.exercise = data
        Task {
            store.exercise.update(exercise: data)
            let _ = try await ExerciseRepository.shared.post(data: data)
            store.exercise.updateExercises()
        }
    }
}

struct RecordFormDependencyImpl: RecordFormDependency {
    
    @Binding var paths: [ContentView.NavigationPath]
    
    func addExercise() {
        paths.append(.exerciseForm(nil, nil, "", [], true))
    }
    
    func addSet() {
        paths.append(.setForm)
    }
    
    func save(record: Record) {
        let _ = paths.popLast()
        HistoryFormNotificationCenter.shared.record = record
    }
    
    func tapPreviusRecordButton(record: Record, dateString: String) {
        paths.append(.recordSets(record, dateString))
    }
    
    func tapListButton() {
        paths.append(.selectExercise)
    }
}

struct HistoryFormDependencyImpl: HistoryFormDependency {
    
    @Binding var showingErrorState: ContentView.ShowingErrorState
    @Binding var paths: [ContentView.NavigationPath]
    
    func tap(record: Record, dateString: String) {
        let exercise = store.exercise.exercises.first(where: { $0.id == record.exerciseId })
        paths.append(.recordForm(exercise, record.sets, dateString))
    }
    
    func tapAdd(dateString: String) {
        paths.append(.recordForm(nil, [], dateString))
    }
    
    func tapSave(data: ExerciseHistory) {
        Task {
            do {
                let _ = paths.popLast()
                store.history.update(history: data)
                let _ = try await HistoryRepository.shared.post(data: data)
                store.history.updateHistories()
            } catch {
                DispatchQueue.main.async {
                    withAnimation {
                        showingErrorState = .init(showing: true, message: error.localizedDescription)
                    }
                }
            }
        }
    }
}

struct ExerciseDiaryDependencyImpl: ExerciseDiaryDependency {
    
    @Binding var paths: [ContentView.NavigationPath]
    @Binding var monthlyChartViewIngredient: ContentView.MonthlyChartViewIngredient
    
    func tapAddHistory() {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateString = dateFormatter.string(from: Date())
        
        if let history = store.history.histories.first(where: { $0.date == dateString }) {
            paths.append(.historyForm(history.id, history.date, history.records))
        } else {
            paths.append(.historyForm(nil, nil, []))
        }
    }
    
    func tapHistory(history: ExerciseHistory) {
        paths.append(.historyForm(history.id, history.date, history.records))
    }
    
    func scrollBottom() {
        store.history.appendHistories()
    }
    
    func delete(data: ExerciseHistory) {
        Task {
            store.history.delete(history: data)
            let _ = try await HistoryRepository.shared.delete(data: data)
            store.history.updateHistories()
        }
    }
    
    func tapChart(histories: [ExerciseHistory], volumeByPart: [String: Double]) {
        monthlyChartViewIngredient.exerciseHistories = histories
        monthlyChartViewIngredient.volumeBasedOnExercise = volumeByPart
        withAnimation {
            monthlyChartViewIngredient.showing = true
        }
    }
    
    func tapProfile() {
        paths.append(.setting)
    }
    
    func tapGrass(histories: [ExerciseHistory], volumeByPart: [String : Double]) {
        monthlyChartViewIngredient.exerciseHistories = histories
        monthlyChartViewIngredient.volumeBasedOnExercise = volumeByPart
        withAnimation {
            monthlyChartViewIngredient.showing = true
        }
    }
}

struct WithdrawalConfirmDependencyImpl: WithdrawalConfirmDependency {
    
    @Binding var showingErrorState: ContentView.ShowingErrorState
    
    func delete() {
        Task {
            if let error = await Authenticator().withDrawal() {
                DispatchQueue.main.async {
                    withAnimation {
                        showingErrorState = .init(showing: true, message: error.localizedDescription)
                    }
                }
            }
            store.user.updateUser()
        }
    }
}

struct ProfilePhotoPickerDependencyImpl: PhotoPickerViewDependency {
    
    @Binding var loadingState: ContentView.LoadingState
    @Binding var showingErrorState: ContentView.ShowingErrorState
    @Binding var showingSuccessState: ContentView.ShowingSuccessState
    
    func saveProfileImage(image: UIImage?) {
        guard let uid = store.user.uid else { return }
        
        withAnimation {
            loadingState = .init(showing: true)
        }
        
        Task {
            if let previousPhotoURLString = store.user.photoURL?.absoluteString, let path = URL(string: previousPhotoURLString)?.lastPathComponent {
                try await FileUploader.shared.deleteImage(path: "profilePhoto/\(uid)/\(path)")
            }
            store.user.updateUser()
        }
        
        Task {
            do {
                if let image {
                    let url = try await FileUploader.shared.uploadImage(path: "profilePhoto/\(uid)/\(UUID().uuidString).png", image: image)
                    try await Authenticator().updateUser(displayName: store.user.displayName, photoURL: url)
                } else {
                    try await Authenticator().updateUser(displayName: store.user.displayName, photoURL: nil)
                }
                store.user.updateUser()
                
                withAnimation {
                    showingSuccessState = .init(showing: true, message: "profile photo successfully uploaded")
                    loadingState = .init(showing: false)
                }
            } catch {
                withAnimation {
                    showingErrorState = .init(showing: true, message: error.localizedDescription)
                    loadingState = .init(showing: false)
                }
            }
        }
    }
}

struct BodyProfileViewDependencyImpl: BodyProfileViewDependency {
    
    @Binding var paths: [ContentView.NavigationPath]
    @Binding var isShowingProfilePhotoPicker: Bool
    @Binding var showingErrorState: ContentView.ShowingErrorState
    
    func tapSave(displayName: String) {
        Task {
            let _ = paths.popLast()
            guard let id = store.user.uid else { return }
            
            let profile = Profile(id: id, photoURL: store.user.photoURL?.absoluteString, displayName: displayName, updatedAt: nil)
            store.user.set(displayName: displayName, profile: profile)
            
            try await Authenticator().updateUser(displayName: displayName.isEmpty ? nil : displayName, photoURL: store.user.photoURL)
            let response = try await UserRepository.shared.postProfile(profile: profile)
            
            store.user.updateUser()
            
            if let errorMessage = response.message {
                withAnimation {
                    showingErrorState = .init(showing: true, message: errorMessage)
                }
            }
        }
    }
    
    func tapProfileImage() {
        withAnimation {
            isShowingProfilePhotoPicker = true
        }
    }
    
    func openHealthApp() {
        guard let url = URL(string: "x-apple-health://") else { return }
        UIApplication.shared.open(url)
    }
}

struct SettingViewDependencyImpl: SettingViewDependency {
    @Binding var paths: [ContentView.NavigationPath]
    @Binding var isPresentedWithDrawalConfirm: Bool
    
    func tapProfileSection() {
        paths.append(.bodyProfile)
    }
    
    func tapExercise() {
        paths.append(.exerciseList)
    }
    
    func tapLogout() {
        do {
            try Authenticator().signOut()
            store.user.updateUser()
        } catch {
            print("fail to logout")
        }
    }
    
    func tapWithdrawal() {
        withAnimation {
            isPresentedWithDrawalConfirm = true
        }
    }
    
    func tapExerciseList() {
        paths.append(.exerciseGuideList)
    }
    
    func tapWatchApp() {
        paths.append(.watchWorkoutAppInfoView)
    }
}

struct ExerciseInfoContainerDependencyImpl: ExerciseInfoContainerDependency {
    
    @Binding var loadingState: ContentView.LoadingState
    @Binding var showingErrorState: ContentView.ShowingErrorState
    @Binding var showingSuccessState: ContentView.ShowingSuccessState
    
    func addExercise(exercise: Exercise) {
        Task {
            var exercises = store.exercise.exercises
            exercises.append(exercise)
            store.exercise.set(exercises: exercises)
            withAnimation {
                loadingState = .init(showing: true, message: "please don't quit the app")
            }
            let response = try await ExerciseRepository.shared.set(exercises: exercises)
            withAnimation {
                loadingState = .init(showing: false)
            }
            
            store.exercise.updateExercises()
            
            if let errorMessage = response.message {
                withAnimation {
                    showingErrorState = .init(showing: true, message: errorMessage)
                }
            } else {
                withAnimation {
                    showingSuccessState = .init(showing: true, message: "successfully added")
                }
            }
        }
    }
}
