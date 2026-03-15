import SwiftUI
import Foundation

// This view is now driven by your ProfileViewModel
struct ReminderSettingsView: View {
    @ObservedObject var viewModel: ProfileViewModel

    // Create a local @State copy for editing
    @State private var settings: ReminderSettings

    @Environment(\.dismiss) private var dismiss

    // DateFormatter for parsing time strings (supports multiple formats from API)
    private let parseFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()

    // DateFormatter for API output (H:i format = "17:00")
    private let apiFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm" // Laravel expects "H:i" which is "17:00"
        return formatter
    }()

    // Binding helper to convert String to Date for DatePickers
    private func timeBinding(for timeString: Binding<String>) -> Binding<Date> {
        return Binding(
            get: {
                // Try to parse various formats
                let value = timeString.wrappedValue
                // Try "HH:mm:ss" format first
                if let date = parseFormatter.date(from: value) {
                    return date
                }
                // Try "HH:mm" format
                if let date = apiFormatter.date(from: value) {
                    return date
                }
                return Date()
            },
            set: {
                // Always save in "HH:mm" format for API compatibility
                timeString.wrappedValue = apiFormatter.string(from: $0)
            }
        )
    }

    init(viewModel: ProfileViewModel, settings: ReminderSettings) {
        self.viewModel = viewModel
        self._settings = State(initialValue: settings)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("reminder.meal_reminders".localizedString)) {
                    Toggle("reminder.breakfast".localizedString, isOn: $settings.breakfast_enabled)
                    if settings.breakfast_enabled {
                        DatePicker("reminder.time".localizedString, selection: timeBinding(for: $settings.breakfast_time), displayedComponents: .hourAndMinute)
                    }

                    Toggle("reminder.lunch".localizedString, isOn: $settings.lunch_enabled)
                    if settings.lunch_enabled {
                        DatePicker("reminder.time".localizedString, selection: timeBinding(for: $settings.lunch_time), displayedComponents: .hourAndMinute)
                    }

                    Toggle("reminder.dinner".localizedString, isOn: $settings.dinner_enabled)
                    if settings.dinner_enabled {
                        DatePicker("reminder.time".localizedString, selection: timeBinding(for: $settings.dinner_time), displayedComponents: .hourAndMinute)
                    }
                }

                Section(header: Text("reminder.workout_reminder".localizedString)) {
                    Toggle("reminder.workout".localizedString, isOn: $settings.workout_enabled)
                    if settings.workout_enabled {
                        DatePicker("reminder.time".localizedString, selection: timeBinding(for: $settings.workout_time), displayedComponents: .hourAndMinute)
                    }
                }
            }
            .navigationTitle("reminder.title".localizedString)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel".localizedString) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("common.save".localizedString) {
                        viewModel.saveReminderSettings(settings: self.settings)
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
        breakfast_enabled: true, breakfast_time: "08:00",
        lunch_enabled: true, lunch_time: "12:00",
        dinner_enabled: false, dinner_time: "19:00",
        workout_enabled: true, workout_time: "17:00"
    )

    return ReminderSettingsView(
        viewModel: PreviewProfileViewModel(),
        settings: sampleSettings
    )
}
