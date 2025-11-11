import SwiftUI

struct EnhancedWorkoutView: View {
    @ObservedObject var viewModel: WorkoutsViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(viewModel.workoutSessions.sorted(by: { $0.id > $1.id })) { workout in
                    WorkoutCard(workout: workout)
                }
            }
            .padding()
        }
        .navigationTitle("Workouts")
    }
}

private struct WorkoutCard: View {
    let workout: WorkoutSession

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(workout.day)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Color.appTheme.textSecondary)
                
                Spacer()
                
                if let isCompleted = workout.is_completed, isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            Text(workout.theme)
                .font(.headline)
                .foregroundColor(Color.appTheme.primary)

            if let exercises = workout.exercises {
                ForEach(exercises) { exercise in
                    ExerciseRow(exercise: exercise)
                }
            }

            if let warmup = workout.warmup {
                Text("Warmup: \(warmup)")
                    .font(.caption)
                    .foregroundColor(Color.appTheme.textSecondary)
            }
            
            if let finisher = workout.finisher {
                Text("Finisher: \(finisher)")
                    .font(.caption)
                    .foregroundColor(Color.appTheme.textSecondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.appTheme.surface)
                .shadow(radius: 5)
        )
    }
}

private struct ExerciseRow: View {
    let exercise: WorkoutExercise

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.subheadline)
                    .foregroundColor(Color.appTheme.textPrimary)

                HStack(spacing: 8) {
                    Text("Sets: \(exercise.sets)")
                        .font(.caption)
                        .foregroundColor(Color.appTheme.textSecondary)
                    
                    Text("•")
                        .foregroundColor(Color.appTheme.textTertiary)
                    
                    Text("Reps: \(exercise.reps)")
                        .font(.caption)
                        .foregroundColor(Color.appTheme.textSecondary)
                    
                    Text("•")
                        .foregroundColor(Color.appTheme.textTertiary)
                    
                    Text("Recovery: \(exercise.recovery)")
                        .font(.caption)
                        .foregroundColor(Color.appTheme.textSecondary)
                }
            }
            
            Spacer()
            
            if let isCompleted = exercise.is_completed, isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
}

struct EnhancedWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EnhancedWorkoutView(viewModel: WorkoutsViewModel())
        }
    }
}
