//
//  HistoryFormView.swift
//  dg-muscle-ios
//
//  Created by 신동규 on 9/30/23.
//

import SwiftUI

final class HistoryFormNotificationCenter: ObservableObject {
    static let shared = HistoryFormNotificationCenter()
    @Published var record: Record?
    private init() { }
}

protocol HistoryFormDependency {
    func tap(record: Record, dateString: String)
    func tapAdd(dateString: String)
    func tapSave(data: ExerciseHistory)
}

struct HistoryFormView: View {
    let dependency: HistoryFormDependency
    @StateObject var notificationCenter = HistoryFormNotificationCenter.shared
    let id: String?
    let dateString: String?
    var dateStringValue: String {
        if let dateString {
            return dateString
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.string(from: Date())
    }
    @State var records: [Record]
    @State var saveButtonDisabled: Bool
    
    var body: some View {
        VStack {
            Text("Record Form")
                .font(.largeTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            List {
                ForEach(records) { record in
                    if let exercise = store.exercise.exercises.first(where: { $0.id ==  record.exerciseId}) {
                        
                        Button {
                            dependency.tap(record: record, dateString: dateStringValue)
                        } label: {
                            HStack {
                                Text("\(exercise.name) record")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(Color(uiColor: .label))
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                            }
                        }
                    } else {
                        VStack(spacing: 4) {
                            Text("This record was deleted because of absence of exercise")
                                .italic()
                                .foregroundStyle(.red)
                            Text("(Maybe this is network issue. Please retry later.)")
                                .font(.caption2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(Color(uiColor: .secondaryLabel))
                        }
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach({ records.remove(at: $0) })
                }
                
                Button("Add", systemImage: "plus.circle") {
                    dependency.tapAdd(dateString: dateStringValue)
                }
            }
            
            if saveButtonDisabled == false {
                Button {
                    // TODO: add date selector, add memo input form
                    let data = ExerciseHistory(id: id ?? UUID().uuidString, date: dateStringValue, memo: nil, records: records, createdAt: nil)
                    dependency.tapSave(data: data)
                } label: {
                    Text("Save")
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 10).fill(.blue)
                        }
                        .padding()
                }
            }
        }
        .onChange(of: records) { oldValue, newValue in
            withAnimation {
                saveButtonDisabled = newValue.filter { record in store.exercise.exercises.contains(where: { $0.id == record.exerciseId }) }.isEmpty
            }
        }
        .onChange(of: notificationCenter.record) { _, value in
            if let value {
                withAnimation {
                    if let index = records.firstIndex(where: { $0.exerciseId == value.exerciseId }) {
                        records[index] = value
                    } else {
                        records.append(value)
                    }
                }
            }
        }
    }
}
