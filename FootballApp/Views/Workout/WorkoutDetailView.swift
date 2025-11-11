//
//  WorkoutDetailView.swift
//  FootballApp
//
//  Modern workout session experience with iOS 17+ features
//

import SwiftUI
import AVKit
import os.log

// NOTE: WorkoutState must be defined in WorkoutDetailViewModel.swift (and is assumed to be)

struct WorkoutDetailView: View {
    @StateObject var viewModel: WorkoutDetailViewModel
    var onFinish: () -> Void
    var onCancel: () -> Void
    
    @State private var showVideo = false
    @State private var autoPlayedVideo = false

    var body: some View {
        ZStack {
            // Dynamic background based on state
            workoutBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header (Defined below)
                WorkoutHeader(
                    title: headerTitle,
                    subtitle: headerSubtitle,
                    onCancel: onCancel
                )
                .padding(.horizontal, 20)
                .padding(.top, 12)

                // Content with smooth transitions
                ZStack {
                    switch viewModel.currentState {
                    case .idle:
                        WorkoutSummaryContent(viewModel: viewModel)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .scale(scale: 0.95)),
                                removal: .opacity.combined(with: .move(edge: .leading))
                            ))
                    case .warmup:
                        TimerPhaseView(
                            viewModel: viewModel,
                            title: "Warming Up",
                            subtitle: "Prepare your body",
                            icon: "sun.max.fill",
                            gradient: [Color.theme.orange, Color.theme.error]
                        )
                        .transition(.push(from: .trailing))
                    case .cooldown:
                        TimerPhaseView(
                            viewModel: viewModel,
                            title: "Cooling Down",
                            subtitle: "Recovery time",
                            icon: "snowflake",
                            gradient: [Color.theme.info, Color.theme.accent]
                        )
                        .transition(.push(from: .trailing))
                    case .finished:
                        WorkoutCompletionView(onFinish: onFinish)
                        .transition(.scale(scale: 0.8).combined(with: .opacity))
                    case .workout:
                        ActiveExerciseView(
                            viewModel: viewModel,
                            showVideo: $showVideo
                        )
                        .transition(.push(from: .trailing))
                    case .rest:
                        RestPhaseView(viewModel: viewModel)
                        .transition(.scale(scale: 1.05).combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.85), value: viewModel.currentState)
            }
        }
        .fullScreenCover(isPresented: $showVideo) {
            autoPlayedVideo = false
        } content: {
            if let exercise = viewModel.currentExercise {
                // Pass the WorkoutExercise struct, which is the correct type.
                KineExerciseVideoView(exercise: exercise, isFavorite: .constant(false))
            }
        }
    }
    
    // MARK: - Dynamic Background (Simplified)
    @ViewBuilder
    private var workoutBackground: some View {
        Color.black // Placeholder for dynamic dark background
    }
    
    // MARK: - Header Content
    private var headerTitle: String {
        switch viewModel.currentState {
        case .idle: return "Workout Preview"
        case .warmup: return "Warming Up"
        case .workout: return "Exercise \(viewModel.currentExerciseIndex + 1)"
        case .rest: return "Rest Period"
        case .cooldown: return "Cooling Down"
        case .finished: return "Complete!"
        }
    }
    
    private var headerSubtitle: String {
        switch viewModel.currentState {
        case .idle: return viewModel.session.theme
        case .warmup: return viewModel.session.warmup ?? "Get ready to train"
        case .workout: return viewModel.currentExercise?.name ?? ""
        case .rest: return "Next: \(viewModel.nextExercise?.name ?? "Final")"
        case .cooldown: return viewModel.session.finisher ?? "Almost done"
        case .finished: return "Great work!"
        }
    }
}

// MARK: - COMPONENT DEFINITIONS (Required for compilation)
// NOTE: These structs must be defined in your project (WorkoutUIComponents.swift or similar).
// They are included here ONLY for reference. If your project has a dedicated file for them,
// this block should be deleted, and that file must be clean.

struct WorkoutHeader: View {
    let title: String
    let subtitle: String
    let onCancel: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.title2.bold()).foregroundColor(.white)
                Text(subtitle).font(.subheadline).foregroundColor(.gray)
            }
            Spacer()
            Button(action: onCancel) { Image(systemName: "xmark.circle.fill").font(.title2).foregroundColor(.gray) }
        }
    }
}

struct WorkoutSummaryContent: View {
    @ObservedObject var viewModel: WorkoutDetailViewModel
    var body: some View {
        VStack { Text("Summary Content Placeholder") }
    }
}

struct TimerPhaseView: View {
    @ObservedObject var viewModel: WorkoutDetailViewModel
    let title: String
    let subtitle: String
    let icon: String
    let gradient: [Color]
    var body: some View {
        VStack { Text("Timer View Placeholder") }
    }
}

struct WorkoutCompletionView: View {
    var onFinish: () -> Void
    var body: some View {
        VStack { Text("Finished View Placeholder") }
    }
}

struct ActiveExerciseView: View {
    @ObservedObject var viewModel: WorkoutDetailViewModel
    @Binding var showVideo: Bool
    var body: some View {
        VStack { Text("Active View Placeholder") }
    }
}

struct RestPhaseView: View {
    @ObservedObject var viewModel: WorkoutDetailViewModel
    var body: some View {
        VStack { Text("Rest View Placeholder") }
    }
}
