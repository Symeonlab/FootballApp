//
//  KineExerciseVideoView.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 14/11/2025.
//

import SwiftUI

// Adapter to preserve legacy references
struct KineExerciseVideoView: View {
    let exercise: KineExercise
    @Binding var isFavorite: Bool

    init(exercise: KineExercise, isFavorite: Binding<Bool> = .constant(false)) {
        self.exercise = exercise
        self._isFavorite = isFavorite
    }

    init(exercise: WorkoutExercise, isFavorite: Binding<Bool> = .constant(false)) {
        // Map WorkoutExercise to KineExercise for the player view
        let kine = KineExercise(
            id: exercise.id,
            title: exercise.name,
            description: "",
            categoryId: 0,
            difficulty: nil,
            imageUrl: exercise.video_url
        )
        self.init(exercise: kine, isFavorite: isFavorite)
    }

    var body: some View {
        // Currently, favorite state is managed internally in the player; binding reserved for future use
        KineExerciseVideoPlayerView(exercise: exercise)
    }
}

struct KineExerciseVideoPlayerView: View {
    // Note: If you need to manually connect the favorite action to the KineViewModel,
    // you must inject the viewModel and pass the exercise ID.
    let exercise: KineExercise
    @State private var isFavorite = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Video Section with enhanced styling
                ZStack(alignment: .topTrailing) {
                    if let urlString = exercise.video_url,
                       let videoID = URL(string: urlString)?.lastPathComponent {
                        // InlineYouTubeWebView is assumed to be defined externally
                        InlineYouTubeWebView(videoID: videoID)
                            .aspectRatio(16/9, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    } else {
                        // Enhanced placeholder
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.purple.opacity(0.2), Color.pink.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .aspectRatio(16/9, contentMode: .fit)
                            .overlay {
                                VStack(spacing: 12) {
                                    Image(systemName: "video.slash.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.secondary)
                                    Text("kine.video_unavailable".localized)
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                    
                    // Favorite button overlay
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            // This would need to call viewModel.toggleFavorite(exerciseID: exercise.id)
                            isFavorite.toggle()
                        }
                    }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.title3)
                            .foregroundColor(isFavorite ? .red : .white)
                            .padding(12)
                            .background(.ultraThinMaterial, in: Circle())
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .padding()
                }
                .padding()
                
                // Exercise Details Card
                VStack(alignment: .leading, spacing: 20) {
                    // Title Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text(exercise.name)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        if !exercise.category.isEmpty {
                            HStack(spacing: 8) {
                                Image(systemName: "tag.fill")
                                    .font(.caption)
                                Text(exercise.category)
                                    .font(.subheadline)
                            }
                            .foregroundColor(.purple)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.purple.opacity(0.1))
                            .clipShape(Capsule())
                        }
                    }
                    
                    Divider()
                    
                    // Exercise Info (if available)
                    HStack(spacing: 12) {
                        if !exercise.category.isEmpty {
                            InfoPill(icon: "list.bullet", text: exercise.category, color: .purple)
                        }
                        if !exercise.sub_category.isEmpty {
                            InfoPill(icon: "tag", text: exercise.sub_category, color: .pink)
                        }
                        if let metValue = exercise.met_value {
                            InfoPill(icon: "flame.fill", text: String(format: "%.1f MET", metValue), color: .orange)
                        }
                    }
                    
                    if !exercise.category.isEmpty || !exercise.sub_category.isEmpty || exercise.met_value != nil {
                        Divider()
                    }
                    
                    // Description Section
                    if !exercise.description.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Instructions", systemImage: "list.bullet.clipboard")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(exercise.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .lineSpacing(6)
                        }
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                .padding(.horizontal)
            }
            .padding(.bottom, 32)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}

extension KineExerciseVideoPlayerView {
    init(workoutExercise: WorkoutExercise) {
        // Map WorkoutExercise to KineExercise
        let kine = KineExercise(
            id: workoutExercise.id,
            title: workoutExercise.name,
            description: "",
            categoryId: 0,
            difficulty: nil,
            imageUrl: workoutExercise.video_url
        )
        self.init(exercise: kine)
    }
}

// MARK: - Info Pill Component (Defined locally for compilation clarity)
struct InfoPill: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(color)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .clipShape(Capsule())
    }
}
