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
        NavigationView {
            Form {
                Section(header: Text("Date")) {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                Section(header: Text("Measurements")) {
                    HStack {
                        TextField("Weight", text: $weight).keyboardType(.decimalPad)
                        Text("kg").foregroundColor(.secondary)
                    }
                    HStack {
                        TextField("Waist", text: $waist).keyboardType(.decimalPad)
                        Text("cm").foregroundColor(.secondary)
                    }
                    HStack {
                        TextField("Chest", text: $chest).keyboardType(.decimalPad)
                        Text("cm").foregroundColor(.secondary)
                    }
                    HStack {
                        TextField("Hips", text: $hips).keyboardType(.decimalPad)
                        Text("cm").foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextField("Mood (e.g., Energized, Tired)", text: $mood)
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                if let saveError = viewModel.errorMessage {
                    Section {
                        Text(saveError).foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Log Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
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
