//
//  WorkoutSelectionView.swift
//  FootballApp
//
//  Dynamic workout selection with personalized recommendations
//


import SwiftUI

struct WorkoutSelectionView: View {
    let sessions: [WorkoutSession]
    let completedWorkouts: Set<Int>
    let onWorkoutSelected: (WorkoutSession) -> Void
    let onGenerateNewPlan: () -> Void // Needed for the regeneration button
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Your Weekly Plan")
                    .font(.headline)
                Spacer()
                // Button now calls the action correctly
                Button("Generate New Plan") { onGenerateNewPlan() }
            }
            .padding(.horizontal)

            List(sessions, id: \.id) { session in
                Button(action: { onWorkoutSelected(session) }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.day)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(session.theme)
                                .font(.body.weight(.semibold))
                                .foregroundColor(.primary)
                        }
                        Spacer()
                        if completedWorkouts.contains(session.id) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 6)
                }
            }
            .listStyle(.insetGrouped)
        }
    }
}

#Preview {
    // Minimal preview with placeholders
    struct Session: Identifiable { let id: Int; let day: String; let title: String }
    let mock: [WorkoutSession] = [] // Replace with real mock if available
    return WorkoutSelectionView(
        sessions: mock,
        completedWorkouts: [],
        onWorkoutSelected: { _ in },
        onGenerateNewPlan: {}
    )
}
