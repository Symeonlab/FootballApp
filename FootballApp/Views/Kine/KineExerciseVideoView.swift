//
//  KineExerciseVideoView.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 14/11/2025.
//

import SwiftUI
import AVKit

// Adapter to preserve legacy references
struct KineExerciseVideoView: View {
    @EnvironmentObject var kineViewModel: KineViewModel
    @Environment(\.dismiss) private var dismiss

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
        KineExerciseVideoPlayerView(exercise: exercise, kineViewModel: kineViewModel, dismiss: dismiss)
    }
}

struct KineExerciseVideoPlayerView: View {
    let exercise: KineExercise
    @ObservedObject var kineViewModel: KineViewModel
    let dismiss: DismissAction

    // Computed property for favorite state from ViewModel
    private var isFavorite: Bool {
        kineViewModel.isFavorite(exercise.id)
    }

    var body: some View {
        ZStack(alignment: .top) {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "0A0A1E"), Color(hex: "12122A"), Color(hex: "0A0A1E")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Video Section
                    videoPlayerView
                        .padding(.horizontal, 16)
                        .padding(.top, 60)

                    // Exercise Details Card
                    exerciseDetailsCard
                }
                .padding(.bottom, 100)
            }

            // Floating top bar with glassmorphism
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.body.bold())
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial, in: Circle())
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                }

                Spacer()

                // Favorite button
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        kineViewModel.toggleFavorite(exerciseID: exercise.id)
                    }
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.body.bold())
                        .foregroundColor(isFavorite ? .red : .white)
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial, in: Circle())
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                }

                // Share button
                Button(action: { shareExercise() }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.body.bold())
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial, in: Circle())
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }

    // MARK: - Video Player View
    @ViewBuilder
    private var videoPlayerView: some View {
        if let urlString = exercise.video_url, !urlString.isEmpty {
            // Check if it's a YouTube URL
            if urlString.isYouTubeURL {
                if let videoID = urlString.youTubeVideoID {
                    // Use EmbeddedYouTubePlayer for inline autoplay
                    EmbeddedYouTubePlayer(videoID: videoID, autoPlay: true)
                        .aspectRatio(16/9, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .shadow(color: Color.purple.opacity(0.3), radius: 20, x: 0, y: 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [Color.purple.opacity(0.4), Color.pink.opacity(0.2), .clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                } else {
                    videoPlaceholder
                }
            } else if let url = URL(string: urlString) {
                // Direct video URL (e.g. .mp4): use native AVPlayer
                if isDirectVideoURL(urlString) {
                    VideoPlayer(player: AVPlayer(url: url))
                        .aspectRatio(16/9, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .shadow(color: Color.purple.opacity(0.3), radius: 20, x: 0, y: 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [Color.purple.opacity(0.4), Color.pink.opacity(0.2), .clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                } else {
                    // Unknown URL scheme: show placeholder with "Watch Video" button
                    videoPlaceholderWithURL(url)
                }
            }
        } else {
            videoPlaceholder
        }
    }

    private var videoPlaceholder: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [Color.purple.opacity(0.3), Color.pink.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .aspectRatio(16/9, contentMode: .fit)
            .overlay {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 80, height: 80)

                        Image(systemName: "video.slash.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.white.opacity(0.7))
                    }

                    Text("kine.video_unavailable".localizedString)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.7))

                    Text("kine.video_will_be_available".localizedString)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
    }

    // MARK: - Exercise Details Card
    private var exerciseDetailsCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title Section
            VStack(alignment: .leading, spacing: 10) {
                Text(exercise.name)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                // Info Pills Row
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        if !exercise.category.isEmpty {
                            EnhancedInfoPill(icon: "figure.strengthtraining.traditional", text: exercise.category, color: .purple)
                        }
                        if !exercise.sub_category.isEmpty {
                            EnhancedInfoPill(icon: "tag", text: exercise.sub_category, color: .pink)
                        }
                        if let metValue = exercise.met_value {
                            EnhancedInfoPill(icon: "flame.fill", text: String(format: "%.1f MET", metValue), color: .orange)
                        }
                    }
                }
            }

            // Description Section
            if !exercise.description.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "text.alignleft")
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.purple, .pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Text("kine.instructions".localizedString)
                            .font(.subheadline.bold())
                            .foregroundColor(.white.opacity(0.9))
                    }

                    Text(exercise.description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.75))
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.04))
                )
            }

            // Action Buttons
            HStack(spacing: 12) {
                // Toggle favorite button
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        kineViewModel.toggleFavorite(exerciseID: exercise.id)
                    }
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .symbolEffect(.bounce, value: isFavorite)
                        Text(isFavorite ? "kine.remove_from_favorites".localizedString : "kine.add_to_favorites".localizedString)
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(isFavorite ? .white : .purple)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(isFavorite ? Color.red : Color.purple.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(
                                        isFavorite ? Color.clear : Color.purple.opacity(0.3),
                                        lineWidth: 1
                                    )
                            )
                    )
                }

                // Share button
                Button(action: shareExercise) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.body.weight(.semibold))
                        .foregroundColor(.white.opacity(0.9))
                        .frame(width: 50, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.white.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        )
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .opacity(0.3)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.15), Color.white.opacity(0.05), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .padding(.horizontal, 16)
    }

    // MARK: - Helper Methods

    private func isDirectVideoURL(_ urlString: String) -> Bool {
        let videoExtensions = ["mp4", "mov", "m4v", "avi", "mkv", "webm"]
        if let url = URL(string: urlString) {
            return videoExtensions.contains(url.pathExtension.lowercased())
        }
        return false
    }

    @ViewBuilder
    private func videoPlaceholderWithURL(_ url: URL) -> some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [Color.purple.opacity(0.3), Color.pink.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .aspectRatio(16/9, contentMode: .fit)
            .overlay {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 80, height: 80)

                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.white.opacity(0.8))
                    }

                    SafariLinkButton(url: url, label: "kine.watch_video".localizedString)
                }
            }
            .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
    }

    private func shareExercise() {
        let shareText = "Check out this exercise: \(exercise.name)"
        let activityViewController = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityViewController, animated: true)
        }
    }
}

// MARK: - Safari Link Button
/// A button that opens a URL in SFSafariViewController when tapped.
private struct SafariLinkButton: View {
    let url: URL
    let label: String
    @State private var showSafari = false

    var body: some View {
        Button(action: { showSafari = true }) {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.purple)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
        }
        .fullScreenCover(isPresented: $showSafari) {
            SafariView(url: url)
                .ignoresSafeArea()
        }
    }
}

// MARK: - Enhanced Info Pill Component
struct EnhancedInfoPill: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption.weight(.semibold))
            Text(text)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .foregroundColor(color)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(color.opacity(0.15))
                .overlay(
                    Capsule()
                        .strokeBorder(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Info Pill Component (Legacy support)
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

// MARK: - Preview Wrapper
struct KineExerciseVideoPreviewWrapper: View {
    @StateObject private var kineVM = KineViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        let mockExercise = KineExercise(
            id: 1,
            title: "Hip Flexor Stretch",
            description: "A great stretch for your hip flexors. Hold for 30 seconds on each side.",
            categoryId: 1,
            difficulty: "Easy",
            imageUrl: "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
        )

        KineExerciseVideoPlayerView(
            exercise: mockExercise,
            kineViewModel: kineVM,
            dismiss: dismiss
        )
    }
}

#Preview {
    KineExerciseVideoPreviewWrapper()
        .preferredColorScheme(.dark)
}
