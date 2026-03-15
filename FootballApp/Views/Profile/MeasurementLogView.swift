//
//  MeasurementLogView.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 14/11/2025.
//

import SwiftUI

struct MeasurementLogView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) var dismiss
    
    // Local state for the form
    @State private var date = Date()
    @State private var weight = ""
    @State private var waist = ""
    @State private var chest = ""
    @State private var hips = ""
    @State private var mood = ""
    @State private var notes = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("measurement.date".localizedString)) {
                    DatePicker("measurement.date".localizedString, selection: $date, displayedComponents: .date)
                }

                Section(header: Text("measurement.measurements".localizedString)) {
                    HStack {
                        TextField("measurement.weight".localizedString, text: $weight).keyboardType(.decimalPad)
                        Text("kg").foregroundColor(.secondary)
                    }
                    HStack {
                        TextField("measurement.waist".localizedString, text: $waist).keyboardType(.decimalPad)
                        Text("cm").foregroundColor(.secondary)
                    }
                    HStack {
                        TextField("measurement.chest".localizedString, text: $chest).keyboardType(.decimalPad)
                        Text("cm").foregroundColor(.secondary)
                    }
                    HStack {
                        TextField("measurement.hips".localizedString, text: $hips).keyboardType(.decimalPad)
                        Text("cm").foregroundColor(.secondary)
                    }
                }

                Section(header: Text("measurement.notes".localizedString)) {
                    TextField("measurement.mood".localizedString, text: $mood)
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                if let saveError = viewModel.errorMessage {
                    Section {
                        Text(saveError).foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("measurement.log_progress".localizedString)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel".localizedString) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("common.save".localizedString) {
                        saveProgress()
                    }
                    .disabled(viewModel.isLoading)
                }
            }
        }
    }
    
    private func saveProgress() {
        viewModel.logProgress(
            date: date,
            weight: weight,
            waist: waist,
            chest: chest,
            hips: hips,
            notes: notes,
            mood: mood
        ) { success in
            if success {
                dismiss()
            }
        }
    }
}
