import SwiftUI
import Foundation

// This view is now driven by your ProfileViewModel
struct ReminderSettingsView: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    // Create a local @State copy for editing
    @State private var settings: ReminderSettings
    
    @Environment(\.dismiss) private var dismiss
    
    // DateFormatter for converting "HH:mm:ss" string to Date
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss" // Matches Laravel's default
        return formatter
    }()
    
    // Binding helper to convert String to Date for DatePickers
    private func timeBinding(for timeString: Binding<String>) -> Binding<Date> {
        return Binding(
            get: {
                // Convert "17:00:00" string to a Date object
                return timeFormatter.date(from: timeString.wrappedValue) ?? Date()
            },
            set: {
                // Convert Date object back to a "HH:mm:ss" string
                timeString.wrappedValue = timeFormatter.string(from: $0)
            }
        )
    }

    init(viewModel: ProfileViewModel, settings: ReminderSettings) {
        self.viewModel = viewModel
        self._settings = State(initialValue: settings)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Meal Reminders")) {
                    Toggle("Breakfast", isOn: $settings.breakfast_enabled)
                    if settings.breakfast_enabled {
                        DatePicker("Time", selection: timeBinding(for: $settings.breakfast_time), displayedComponents: .hourAndMinute)
                    }
                    
                    Toggle("Lunch", isOn: $settings.lunch_enabled)
                    if settings.lunch_enabled {
                        DatePicker("Time", selection: timeBinding(for: $settings.lunch_time), displayedComponents: .hourAndMinute)
                    }
                    
                    Toggle("Dinner", isOn: $settings.dinner_enabled)
                    if settings.dinner_enabled {
                        DatePicker("Time", selection: timeBinding(for: $settings.dinner_time), displayedComponents: .hourAndMinute)
                    }
                }
                
                Section(header: Text("Workout Reminder")) {
                    Toggle("Workout", isOn: $settings.workout_enabled)
                    if settings.workout_enabled {
                        DatePicker("Time", selection: timeBinding(for: $settings.workout_time), displayedComponents: .hourAndMinute)
                    }
                }
            }
            .navigationTitle("Reminder Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // --- THIS IS THE FIX ---
                        // Pass the local 'settings' struct to the view model
                        viewModel.saveReminderSettings(settings: self.settings)
                        // --- END OF FIX ---
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview Code
#Preview("Reminder Settings") {
    
    // Create a mock ViewModel for the preview
    class PreviewProfileViewModel: ProfileViewModel {
        override init() {
            super.init()
            // Override init to stop it from fetching data
        }
    }
    
    // Create a sample ReminderSettings struct
    let sampleSettings = ReminderSettings(
        id: 1,
        breakfast_enabled: true, breakfast_time: "08:00:00",
        lunch_enabled: true, lunch_time: "12:00:00",
        dinner_enabled: false, dinner_time: "19:00:00",
        workout_enabled: true, workout_time: "17:00:00"
    )
    
    return ReminderSettingsView(
        viewModel: PreviewProfileViewModel(),
        settings: sampleSettings
    )
}
