//
//  WorkoutSessionReelsView.swift
//  FootballApp
//
//  Full-screen workout experience with exercise reels
//

import SwiftUI
import AVKit
import SafariServices
import WebKit

struct WorkoutSessionReelsView: View {
    @ObservedObject var viewModel: WorkoutDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var currentPhase: WorkoutPhase = .intro
    @State private var currentExerciseIndex: Int = 0
    @State private var showingRestTimer = false
    @State private var appearAnimation = false

    var onComplete: () -> Void

    private enum WorkoutPhase: Equatable {
        case intro, warmup, exercises, cooldown, completion
    }

    // Check if session has valid exercises
    private var hasExercises: Bool {
        guard let exercises = viewModel.session.exercises else { return false }
        return !exercises.isEmpty
    }

    var body: some View {
        ZStack {
            // Dynamic gradient background based on phase
            phaseBackground
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: currentPhase)

            // Phase-based content
            Group {
                switch currentPhase {
                case .intro:
                    WorkoutIntroReelView(
                        session: viewModel.session,
                        onStart: {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()

                            // Start elapsed time tracking
                            viewModel.startElapsedTimer()

                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                if viewModel.session.warmup != nil && !viewModel.session.warmup!.isEmpty {
                                    currentPhase = .warmup
                                } else if hasExercises {
                                    currentPhase = .exercises
                                } else {
                                    // No warmup and no exercises - go straight to completion
                                    currentPhase = .completion
                                    viewModel.currentState = .finished
                                    viewModel.stopElapsedTimer()
                                }
                            }
                        },
                        onDismiss: {
                            dismiss()
                        }
                    )
                    .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .leading).combined(with: .opacity)))

                case .warmup:
                    WarmupReelView(
                        warmupDescription: viewModel.session.warmup ?? "Get ready!",
                        onComplete: {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                if hasExercises {
                                    currentPhase = .exercises
                                } else {
                                    currentPhase = .completion
                                    viewModel.currentState = .finished
                                }
                            }
                        },
                        onSkip: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                if hasExercises {
                                    currentPhase = .exercises
                                } else {
                                    currentPhase = .completion
                                    viewModel.currentState = .finished
                                }
                            }
                        }
                    )
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))

                case .exercises:
                    if hasExercises {
                        if showingRestTimer {
                            RestTimerReelView(
                                restTime: viewModel.timerValue,
                                totalRestTime: viewModel.totalTime,
                                nextExercise: viewModel.nextExercise,
                                currentSet: viewModel.currentSet,
                                totalSets: viewModel.totalSets,
                                onComplete: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        showingRestTimer = false
                                    }
                                },
                                onSkip: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        showingRestTimer = false
                                    }
                                }
                            )
                            .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .scale.combined(with: .opacity)))
                        } else {
                            ExercisesReelsView(
                                exercises: viewModel.session.exercises ?? [],
                                currentIndex: $currentExerciseIndex,
                                currentSet: viewModel.currentSet,
                                totalSets: viewModel.totalSets,
                                onCompleteSet: {
                                    let generator = UINotificationFeedbackGenerator()
                                    generator.notificationOccurred(.success)

                                    viewModel.completeSet()

                                    // Only show rest timer if there's more to do
                                    if viewModel.currentSet < viewModel.totalSets || currentExerciseIndex < (viewModel.session.exercises?.count ?? 0) - 1 {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            showingRestTimer = true
                                        }
                                    }
                                },
                                onCompleteExercise: {
                                    let generator = UINotificationFeedbackGenerator()
                                    generator.notificationOccurred(.success)

                                    if currentExerciseIndex < (viewModel.session.exercises?.count ?? 0) - 1 {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            currentExerciseIndex += 1
                                            viewModel.currentExerciseIndex = currentExerciseIndex
                                            viewModel.currentSet = 1
                                        }
                                    } else {
                                        // All exercises complete
                                        if let finisher = viewModel.session.finisher, !finisher.isEmpty {
                                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                                currentPhase = .cooldown
                                            }
                                        } else {
                                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                                currentPhase = .completion
                                                viewModel.currentState = .finished
                                            }
                                        }
                                    }
                                },
                                onSkip: {
                                    // Skip current exercise entirely
                                    if currentExerciseIndex < (viewModel.session.exercises?.count ?? 0) - 1 {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            currentExerciseIndex += 1
                                            viewModel.currentExerciseIndex = currentExerciseIndex
                                            viewModel.currentSet = 1
                                        }
                                    } else {
                                        // Last exercise - move to cooldown or completion
                                        if let finisher = viewModel.session.finisher, !finisher.isEmpty {
                                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                                currentPhase = .cooldown
                                            }
                                        } else {
                                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                                currentPhase = .completion
                                                viewModel.currentState = .finished
                                            }
                                        }
                                    }
                                }
                            )
                            .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .scale.combined(with: .opacity)))
                        }
                    } else {
                        // No exercises - show empty state
                        NoExercisesView(onDismiss: { dismiss() })
                            .transition(.opacity)
                    }

                case .cooldown:
                    CooldownReelView(
                        cooldownDescription: viewModel.session.finisher ?? "Great work!",
                        onComplete: {
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                currentPhase = .completion
                                viewModel.currentState = .finished
                            }
                        },
                        onSkip: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                currentPhase = .completion
                                viewModel.currentState = .finished
                            }
                        }
                    )
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))

                case .completion:
                    WorkoutCompletionReelsView(
                        sessionDay: viewModel.session.day,
                        sessionTheme: viewModel.session.displayThemeName,
                        totalExercises: viewModel.totalExercisesInSession,
                        elapsedTime: viewModel.elapsedTime,
                        onDismiss: {
                            onComplete()
                            dismiss()
                        }
                    )
                    .transition(.asymmetric(insertion: .scale(scale: 0.8).combined(with: .opacity), removal: .opacity))
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentPhase)

            // Top overlay with progress bar, close button and phase indicator
            VStack(spacing: 0) {
                // Workout-wide phase progress bar
                if currentPhase != .intro && currentPhase != .completion {
                    WorkoutPhaseProgressBar(
                        currentPhase: phaseIndex,
                        exerciseProgress: exerciseProgressFraction,
                        totalPhases: 5
                    )
                    .padding(.top, 12)
                }

                HStack {
                    // Close/back button (always visible except completion)
                    if currentPhase != .completion {
                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            if currentPhase == .intro {
                                dismiss()
                            } else {
                                // Go back to previous phase
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    goToPreviousPhase()
                                }
                            }
                        }) {
                            Image(systemName: currentPhase == .intro ? "xmark" : "chevron.left")
                                .font(.title3.weight(.semibold))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(.ultraThinMaterial.opacity(0.8))
                                .clipShape(Circle())
                        }
                        .padding(.leading)
                    }

                    Spacer()

                    // Phase indicator pill
                    if currentPhase != .intro && currentPhase != .completion {
                        HStack(spacing: 8) {
                            phaseIcon
                                .font(.caption.weight(.semibold))

                            Text(phaseTitle)
                                .font(.system(size: 13, weight: .bold))

                            if currentPhase == .exercises && !showingRestTimer {
                                Text("•")
                                    .foregroundColor(.white.opacity(0.5))
                                Text("\(currentExerciseIndex + 1)/\(viewModel.totalExercisesInSession)")
                                    .font(.system(size: 13, weight: .bold))
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial.opacity(0.8))
                        .clipShape(Capsule())
                        .padding(.trailing)
                    }
                }
                .padding(.top, 8)

                Spacer()
            }
        }
        .preferredColorScheme(.dark)
        .statusBar(hidden: true)
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                appearAnimation = true
            }
        }
        .onChange(of: currentPhase) { _, newPhase in
            if newPhase == .completion {
                viewModel.stopElapsedTimer()
            }
        }
    }

    // MARK: - Helper Views & Properties

    @ViewBuilder
    private var phaseBackground: some View {
        switch currentPhase {
        case .intro:
            LinearGradient(
                colors: themeGradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .warmup:
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.5, blue: 0.2), Color(red: 0.9, green: 0.3, blue: 0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .exercises:
            if showingRestTimer {
                LinearGradient(
                    colors: [Color(red: 0.2, green: 0.3, blue: 0.5), Color(red: 0.15, green: 0.2, blue: 0.4)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                LinearGradient(
                    colors: [Color(red: 0.2, green: 0.15, blue: 0.35), Color(red: 0.15, green: 0.1, blue: 0.25)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        case .cooldown:
            LinearGradient(
                colors: [Color(red: 0.3, green: 0.6, blue: 0.8), Color(red: 0.2, green: 0.4, blue: 0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .completion:
            LinearGradient(
                colors: [Color(red: 0.2, green: 0.8, blue: 0.5), Color(red: 0.1, green: 0.6, blue: 0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var themeGradientColors: [Color] {
        // Use zone-based color when available, with legacy theme-name fallback
        if viewModel.session.metadata?.zoneColor != nil {
            let base = viewModel.session.sessionZoneColor
            return [base, base.opacity(0.7)]
        }
        let theme = viewModel.session.theme.lowercased()
        if theme.contains("force") || theme.contains("strength") {
            return [Color(red: 0.8, green: 0.2, blue: 0.3), Color(red: 0.6, green: 0.1, blue: 0.2)]
        } else if theme.contains("cardio") || theme.contains("endurance") {
            return [Color(red: 0.2, green: 0.5, blue: 0.8), Color(red: 0.1, green: 0.3, blue: 0.6)]
        } else if theme.contains("vitesse") || theme.contains("speed") {
            return [Color(red: 1.0, green: 0.6, blue: 0.0), Color(red: 0.9, green: 0.4, blue: 0.0)]
        } else if theme.contains("flexibility") || theme.contains("mobility") {
            return [Color(red: 0.4, green: 0.8, blue: 0.6), Color(red: 0.3, green: 0.6, blue: 0.5)]
        } else {
            return [Color(red: 0.4, green: 0.3, blue: 0.7), Color(red: 0.3, green: 0.2, blue: 0.5)]
        }
    }

    // Phase index for progress bar: 0=intro, 1=warmup, 2=exercises, 3=cooldown, 4=done
    private var phaseIndex: Int {
        switch currentPhase {
        case .intro: return 0
        case .warmup: return 1
        case .exercises: return 2
        case .cooldown: return 3
        case .completion: return 4
        }
    }

    // Exercise progress within the exercises phase (0-1)
    private var exerciseProgressFraction: Double {
        guard let exercises = viewModel.session.exercises, !exercises.isEmpty else { return 0 }
        let totalEx = Double(exercises.count)
        let completedEx = Double(currentExerciseIndex)
        let setProgress = viewModel.totalSets > 0 ? Double(viewModel.currentSet - 1) / Double(viewModel.totalSets) : 0
        return (completedEx + setProgress) / totalEx
    }

    private var phaseIcon: Image {
        switch currentPhase {
        case .intro: return Image(systemName: "play.circle")
        case .warmup: return Image(systemName: "flame.fill")
        case .exercises: return Image(systemName: showingRestTimer ? "timer" : "figure.run")
        case .cooldown: return Image(systemName: "wind")
        case .completion: return Image(systemName: "checkmark.circle.fill")
        }
    }

    private var phaseTitle: String {
        switch currentPhase {
        case .intro: return "workout.phase.ready".localizedString
        case .warmup: return "workout.phase.warmup".localizedString
        case .exercises: return showingRestTimer ? "workout.phase.rest".localizedString : "workout.phase.exercise".localizedString
        case .cooldown: return "workout.phase.cooldown".localizedString
        case .completion: return "workout.phase.done".localizedString
        }
    }

    private func goToPreviousPhase() {
        switch currentPhase {
        case .warmup:
            currentPhase = .intro
        case .exercises:
            if showingRestTimer {
                showingRestTimer = false
            } else if currentExerciseIndex > 0 {
                currentExerciseIndex -= 1
                viewModel.currentExerciseIndex = currentExerciseIndex
                viewModel.currentSet = 1
            } else if viewModel.session.warmup != nil && !viewModel.session.warmup!.isEmpty {
                currentPhase = .warmup
            } else {
                currentPhase = .intro
            }
        case .cooldown:
            if hasExercises {
                currentPhase = .exercises
                currentExerciseIndex = max(0, (viewModel.session.exercises?.count ?? 1) - 1)
            } else {
                currentPhase = .intro
            }
        default:
            break
        }
    }
}

// MARK: - No Exercises Empty State View
struct NoExercisesView: View {
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 140, height: 140)

                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.5))
            }

            VStack(spacing: 12) {
                Text("workout.no_exercises".localizedString)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                Text("workout.no_exercises_description".localizedString)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Button(action: onDismiss) {
                Text("common.go_back".localizedString)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 40)

            Spacer()
        }
    }
}

// MARK: - Workout Intro Reel
struct WorkoutIntroReelView: View {
    let session: WorkoutSession
    let onStart: () -> Void
    var onDismiss: (() -> Void)? = nil

    @State private var scaleEffect: CGFloat = 0.8
    @State private var opacity: Double = 0
    @State private var pulseAnimation = false
    @State private var showThemeInfo = false

    // Check if this is a rest day
    private var isRestDay: Bool { session.isRestDay }

    private var hasExercises: Bool {
        guard let exercises = session.exercises else { return false }
        return !exercises.isEmpty
    }

    var body: some View {
        ZStack {
            // Animated particles
            ParticleFieldView()

            VStack(spacing: 28) {
                Spacer()

                // Day badge with pulse effect
                Text(session.day.uppercased())
                    .font(.system(size: 14, weight: .bold))
                    .tracking(3)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .scaleEffect(pulseAnimation ? 1.05 : 1.0)
                    .scaleEffect(scaleEffect)
                    .opacity(opacity)

                // Theme title with icon
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 100, height: 100)
                            .scaleEffect(pulseAnimation ? 1.1 : 1.0)

                        Image(systemName: themeIcon)
                            .font(.system(size: 50, weight: .light))
                            .foregroundColor(.white)
                            .shadow(color: .white.opacity(0.3), radius: 10)
                    }

                    HStack(spacing: 10) {
                        Text(session.displayThemeName)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        Button(action: { showThemeInfo = true }) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 18))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .sheet(isPresented: $showThemeInfo) {
                            ThemeInfoView(session: session)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .scaleEffect(scaleEffect)
                .opacity(opacity)

                // Session info cards
                VStack(spacing: 12) {
                    if isRestDay {
                        InfoRow(icon: "moon.zzz.fill", text: "workout.rest_day_recovery".localizedString, color: .cyan)
                    } else {
                        if let exercises = session.exercises, !exercises.isEmpty {
                            InfoRow(icon: "dumbbell.fill", text: String(format: "workout.exercises_count".localizedString, exercises.count), color: .white)
                        }
                        if let warmup = session.warmup, !warmup.isEmpty {
                            InfoRow(icon: "flame.fill", text: String(format: "workout.warmup_label".localizedString, warmup), color: .orange)
                        }
                        if let finisher = session.finisher, !finisher.isEmpty {
                            InfoRow(icon: "bolt.fill", text: String(format: "workout.finisher_label".localizedString, finisher), color: .yellow)
                        }

                        // Zone & training science info
                        if let meta = session.metadata {
                            if let zone = meta.zoneColor {
                                InfoRow(icon: meta.zoneIcon,
                                        text: "\(meta.zoneName) (\(zone.capitalized))",
                                        color: meta.zoneSwiftUIColor)
                            }
                            if meta.rpe != nil {
                                InfoRow(icon: "gauge.medium",
                                        text: "RPE: \(meta.rpeDescription)",
                                        color: .orange)
                            }
                            if let sleep = meta.sleepRecommendation {
                                InfoRow(icon: "moon.fill",
                                        text: "\("workout.sleep_tip".localizedString): \(sleep)",
                                        color: .cyan)
                            }
                            if let hydration = meta.hydrationRecommendation {
                                InfoRow(icon: "drop.fill",
                                        text: "\("workout.hydration_tip".localizedString): \(hydration)",
                                        color: .blue)
                            }
                        }
                    }
                }
                .scaleEffect(scaleEffect)
                .opacity(opacity)

                Spacer()

                // Action buttons
                VStack(spacing: 12) {
                    if isRestDay {
                        // Rest day button
                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            onDismiss?()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3.bold())
                                Text("workout.enjoy_rest".localizedString)
                                    .font(.system(size: 18, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [Color.cyan.opacity(0.8), Color.blue.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .shadow(color: Color.cyan.opacity(0.4), radius: 20, x: 0, y: 10)
                        }
                    } else if hasExercises {
                        // Start workout button
                        Button(action: onStart) {
                            HStack(spacing: 12) {
                                Image(systemName: "play.fill")
                                    .font(.title3.bold())
                                Text("workout.start_workout".localizedString)
                                    .font(.system(size: 18, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.4, green: 0.5, blue: 1.0),
                                        Color(red: 0.6, green: 0.4, blue: 1.0)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .shadow(color: Color(red: 0.5, green: 0.4, blue: 1.0).opacity(0.5), radius: 20, x: 0, y: 10)
                        }
                    } else {
                        // No exercises available
                        VStack(spacing: 8) {
                            Text("workout.no_exercises_available".localizedString)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))

                            Button(action: {
                                onDismiss?()
                            }) {
                                Text("workout.go_back".localizedString)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.white.opacity(0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                    }
                }
                .padding(.horizontal, 32)
                .scaleEffect(scaleEffect)
                .opacity(opacity)

                Spacer()
                    .frame(height: 40)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.1)) {
                scaleEffect = 1.0
                opacity = 1.0
            }

            // Subtle pulse animation
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(0.5)) {
                pulseAnimation = true
            }
        }
    }

    private var themeIcon: String { session.sessionIcon }
}

// MARK: - Info Row
struct InfoRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .padding(.horizontal, 32)
    }
}

// MARK: - Particle Field View
struct ParticleFieldView: View {
    @State private var particleOpacity: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<30, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: CGFloat.random(in: 3...8))
                    .position(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: CGFloat.random(in: 0...geometry.size.height)
                    )
                    .blur(radius: CGFloat.random(in: 1...3))
                    .opacity(particleOpacity * Double.random(in: 0.3...1.0))
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 1.0)) {
                particleOpacity = 1
            }
        }
    }
}

// MARK: - Warmup Reel View
struct WarmupReelView: View {
    let warmupDescription: String
    let onComplete: () -> Void
    let onSkip: () -> Void

    @State private var scaleEffect: CGFloat = 0.8
    @State private var breatheScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.5, blue: 0.2), Color(red: 0.9, green: 0.3, blue: 0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Flame icon with breathing animation
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 160, height: 160)
                        .scaleEffect(breatheScale)

                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 140, height: 140)
                        .scaleEffect(breatheScale * 0.9)

                    Image(systemName: "flame.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.white)
                        .shadow(color: .white.opacity(0.5), radius: 20)
                }
                .scaleEffect(scaleEffect)

                VStack(spacing: 16) {
                    Text("workout.session.warmup".localizedString)
                        .font(.system(size: 22, weight: .bold))
                        .tracking(3)
                        .foregroundColor(.white.opacity(0.9))

                    Text(warmupDescription)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    // Breathing cue
                    Text("workout.session.breathe_and_prepare".localizedString)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.top, 4)
                }

                // Action buttons
                HStack(spacing: 16) {
                    Button(action: onSkip) {
                        Text("workout.skip_warmup".localizedString)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    Button(action: onComplete) {
                        HStack(spacing: 8) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 14))
                            Text("workout.im_ready".localizedString)
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color.white.opacity(0.4), Color.white.opacity(0.2)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding(.horizontal, 40)

                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scaleEffect = 1.0
            }

            // Breathing animation (no auto-advance)
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                breatheScale = 1.12
            }
        }
    }
}

// MARK: - Exercises Reels View
struct ExercisesReelsView: View {
    let exercises: [WorkoutExercise]
    @Binding var currentIndex: Int
    let currentSet: Int
    let totalSets: Int
    let onCompleteSet: () -> Void
    let onCompleteExercise: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(exercises.enumerated()), id: \.offset) { index, exercise in
                ExerciseReelView(
                    exercise: exercise,
                    exerciseNumber: index + 1,
                    totalExercises: exercises.count,
                    currentSet: currentSet,
                    totalSets: totalSets,
                    isCompleted: false,
                    onComplete: {
                        if currentSet < totalSets {
                            onCompleteSet()
                        } else {
                            onCompleteExercise()
                        }
                    },
                    onSkip: onSkip
                )
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

// MARK: - Rest Timer Reel
struct RestTimerReelView: View {
    let restTime: Int
    let totalRestTime: Int
    let nextExercise: WorkoutExercise?
    var currentSet: Int = 1
    var totalSets: Int = 1
    let onComplete: () -> Void
    let onSkip: () -> Void

    @State private var breatheAnimation = false

    var progress: Double {
        guard totalRestTime > 0 else { return 0 }
        return Double(totalRestTime - restTime) / Double(totalRestTime)
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Breathing circle animation
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.white.opacity(0.2), Color.clear],
                            center: .center,
                            startRadius: 80,
                            endRadius: 140
                        )
                    )
                    .frame(width: 280, height: 280)
                    .scaleEffect(breatheAnimation ? 1.1 : 0.9)

                // Background circle
                Circle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 8)
                    .frame(width: 200, height: 200)

                // Progress circle
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [Color.cyan, Color.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1.0), value: progress)

                // Inner content
                VStack(spacing: 6) {
                    Text("workout.session.rest".localizedString)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.6))
                        .tracking(3)

                    Text("\(restTime)")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .contentTransition(.numericText())

                    Text("workout.session.seconds".localizedString)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
            }

            // Set progress indicator
            VStack(spacing: 8) {
                Text("workout.session.set_completed".localizedString)
                    .font(.system(size: 11, weight: .bold))
                    .tracking(2)
                    .foregroundColor(.white.opacity(0.5))

                HStack(spacing: 6) {
                    ForEach(1...totalSets, id: \.self) { set in
                        Circle()
                            .fill(set <= currentSet ? Color.cyan : Color.white.opacity(0.3))
                            .frame(width: 10, height: 10)
                    }
                }
            }

            // Next exercise preview card
            if let next = nextExercise {
                VStack(spacing: 10) {
                    Text("workout.session.up_next".localizedString)
                        .font(.system(size: 11, weight: .bold))
                        .tracking(2)
                        .foregroundColor(.white.opacity(0.5))

                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 44, height: 44)

                            Image(systemName: "dumbbell.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.cyan)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(next.name)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)

                            HStack(spacing: 8) {
                                Text(next.sets)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                Text("•")
                                    .foregroundColor(.white.opacity(0.3))
                                Text(next.reps)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }

                        Spacer()
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.ultraThinMaterial.opacity(0.5))
                    )
                }
                .padding(.horizontal, 32)
            }

            Spacer()

            // Skip button
            Button(action: {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                onSkip()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 14))
                    Text("workout.session.skip_rest".localizedString)
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.white.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .onAppear {
            // Start breathing animation
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                breatheAnimation = true
            }
        }
    }
}

// MARK: - Cooldown Reel View
struct CooldownReelView: View {
    let cooldownDescription: String
    let onComplete: () -> Void
    let onSkip: () -> Void

    @State private var scaleEffect: CGFloat = 0.8
    @State private var breatheScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.3, green: 0.6, blue: 0.8), Color(red: 0.2, green: 0.4, blue: 0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Cooldown icon with breathing animation
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 160, height: 160)
                        .scaleEffect(breatheScale)

                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 140, height: 140)
                        .scaleEffect(breatheScale * 0.9)

                    Image(systemName: "figure.cooldown")
                        .font(.system(size: 70))
                        .foregroundColor(.white)
                        .shadow(color: .white.opacity(0.5), radius: 20)
                }
                .scaleEffect(scaleEffect)

                VStack(spacing: 16) {
                    Text("workout.session.cooldown".localizedString)
                        .font(.system(size: 22, weight: .bold))
                        .tracking(3)
                        .foregroundColor(.white.opacity(0.9))

                    Text(cooldownDescription)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    Text("workout.session.stretch_and_breathe".localizedString)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.top, 4)
                }

                // Action buttons
                HStack(spacing: 16) {
                    Button(action: onSkip) {
                        Text("workout.skip_cooldown".localizedString)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    Button(action: onComplete) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                            Text("workout.finish_workout".localizedString)
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color.white.opacity(0.4), Color.white.opacity(0.2)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding(.horizontal, 40)

                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scaleEffect = 1.0
            }

            // Breathing animation (no auto-advance)
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                breatheScale = 1.1
            }
        }
    }
}

struct ExerciseReelView: View {
    let exercise: WorkoutExercise
    let exerciseNumber: Int
    let totalExercises: Int
    let currentSet: Int
    let totalSets: Int
    let isCompleted: Bool
    let onComplete: () -> Void
    let onSkip: () -> Void

    @State private var showSafariPlayer = false

    // Check if URL is a YouTube URL
    private var isYouTubeVideo: Bool {
        guard let urlString = exercise.video_url else { return false }
        return urlString.isYouTubeURL
    }

    // Extract YouTube video ID using shared utility
    private var youtubeVideoID: String? {
        exercise.video_url?.youTubeVideoID
    }

    // YouTube watch URL for Safari
    private var youtubeWatchURL: URL? {
        guard let videoID = youtubeVideoID else { return nil }
        return URL(string: "https://www.youtube.com/watch?v=\(videoID)")
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Full-screen video background
                videoBackground
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()

                // Gradient overlay for readability
                VStack(spacing: 0) {
                    // Top gradient
                    LinearGradient(
                        colors: [Color.black.opacity(0.5), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 120)

                    Spacer()

                    // Bottom gradient for info card
                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.7), Color.black.opacity(0.9)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: geometry.size.height * 0.5)
                }
                .allowsHitTesting(false)

                // Content overlay
                VStack(spacing: 0) {
                    Spacer()

                    // Exercise info card - bottom aligned
                    exerciseInfoCard
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                }
            }
        }
        .fullScreenCover(isPresented: $showSafariPlayer) {
            if let url = youtubeWatchURL {
                WorkoutSafariView(url: url)
                    .ignoresSafeArea()
            }
        }
    }

    // MARK: - Video Background
    @ViewBuilder
    private var videoBackground: some View {
        if let videoURL = exercise.video_url, !videoURL.isEmpty {
            if isYouTubeVideo, let videoID = youtubeVideoID {
                // YouTube video - auto-playing inline player
                InlineYouTubePlayerView(videoID: videoID)
            } else if let url = URL(string: videoURL) {
                // Direct video URL - use AVPlayer
                VideoPlayerView(url: url)
            }
        } else {
            // Gradient placeholder with icon
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.15, green: 0.1, blue: 0.3),
                        Color(red: 0.25, green: 0.15, blue: 0.4)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 100, weight: .thin))
                    .foregroundColor(.white.opacity(0.15))
            }
        }
    }

    // MARK: - Exercise Info Card
    private var exerciseInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Top row: Exercise number + YouTube button
            HStack {
                // Exercise number badge
                Text(String(format: NSLocalizedString("workout.exercise_of", comment: ""), exerciseNumber, totalExercises))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.15), in: Capsule())

                Spacer()

                // YouTube fullscreen button
                if isYouTubeVideo {
                    Button(action: { showSafariPlayer = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "play.rectangle.fill")
                                .font(.system(size: 14, weight: .semibold))
                            Text("YouTube")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.9), in: Capsule())
                    }
                }
            }

            // Exercise name
            Text(exercise.name)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(2)

            // Exercise details pills
            HStack(spacing: 10) {
                ExercisePill(icon: "repeat", text: exercise.reps, color: .green)
                ExercisePill(icon: "square.stack.3d.up", text: exercise.sets, color: .purple)
                ExercisePill(icon: "timer", text: exercise.recovery, color: .orange)
            }

            // Set progress indicator
            HStack(spacing: 10) {
                Text(String(format: NSLocalizedString("workout.complete_set_x_of_y", comment: ""), currentSet, totalSets))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))

                HStack(spacing: 8) {
                    ForEach(1...totalSets, id: \.self) { set in
                        Circle()
                            .fill(set <= currentSet ? Color.purple : Color.white.opacity(0.2))
                            .frame(width: 14, height: 14)
                            .overlay(
                                Circle()
                                    .stroke(set <= currentSet ? Color.purple.opacity(0.6) : Color.white.opacity(0.3), lineWidth: 1.5)
                            )
                            .scaleEffect(set == currentSet ? 1.15 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: currentSet)
                    }
                }
            }

            // Action buttons
            HStack(spacing: 12) {
                // Skip button
                Button(action: onSkip) {
                    Text(NSLocalizedString("workout.session.skip", comment: ""))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
                }

                // Complete set button - dynamic text
                Button(action: onComplete) {
                    HStack(spacing: 8) {
                        Image(systemName: currentSet >= totalSets ? "star.fill" : "checkmark")
                            .font(.system(size: 16, weight: .bold))
                        Text(currentSet >= totalSets
                            ? NSLocalizedString("workout.finish_last_set", comment: "")
                            : String(format: NSLocalizedString("workout.complete_set_x_of_y", comment: ""), currentSet, totalSets))
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: currentSet >= totalSets ? [Color.green, Color.green.opacity(0.7)] : [Color.purple, Color.blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 14)
                    )
                    .shadow(color: Color.purple.opacity(0.4), radius: 12, x: 0, y: 6)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial.opacity(0.9))
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: -10)
        )
    }
}

// MARK: - Exercise Pill (Simplified)
private struct ExercisePill: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
            Text(text)
                .font(.system(size: 13, weight: .semibold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.3), in: Capsule())
    }
}

// MARK: - Detail Pill
struct DetailPill: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(text)
                .font(.system(size: 13, weight: .semibold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.3))
        .clipShape(Capsule())
    }
}

// MARK: - Video Player View
struct VideoPlayerView: View {
    let url: URL
    @State private var player: AVPlayer?
    
    var body: some View {
        VideoPlayer(player: player)
            .disabled(true)
            .onAppear {
                player = AVPlayer(url: url)
                player?.play()
                player?.actionAtItemEnd = .none
                
                NotificationCenter.default.addObserver(
                    forName: .AVPlayerItemDidPlayToEndTime,
                    object: player?.currentItem,
                    queue: .main
                ) { _ in
                    player?.seek(to: .zero)
                    player?.play()
                }
            }
            .onDisappear {
                player?.pause()
                player = nil
            }
    }
}

// MARK: - Video Player Full Screen
struct VideoPlayerFullScreen: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            VideoPlayerView(url: url)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .padding()
                    
                    Spacer()
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Workout Completion Reels View
struct WorkoutCompletionReelsView: View {
    let sessionDay: String
    let sessionTheme: String
    let totalExercises: Int
    var elapsedTime: TimeInterval = 0
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var showConfetti = false
    @State private var showFeedback = false

    // Curated motivational messages
    private static let motivationalMessages = [
        "workout.motivation.champion",
        "workout.motivation.unstoppable",
        "workout.motivation.crushed_it",
        "workout.motivation.beast_mode",
        "workout.motivation.on_fire"
    ]

    private var motivationalKey: String {
        Self.motivationalMessages.randomElement() ?? "workout.motivation.champion"
    }

    private var formattedTime: String {
        guard elapsedTime > 0 else { return "--:--" }
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private var estimatedCalories: Int {
        // Rough estimate: ~7 kcal per minute of moderate workout
        guard elapsedTime > 0 else { return totalExercises * 25 }
        return Int(elapsedTime / 60.0 * 7.0)
    }

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.2, green: 0.8, blue: 0.5),
                    Color(red: 0.1, green: 0.6, blue: 0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Confetti effect
            if showConfetti {
                ConfettiView()
            }

            VStack(spacing: 32) {
                Spacer()

                // Success icon
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 160, height: 160)

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white, Color.white.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: .white.opacity(0.6), radius: 30, x: 0, y: 10)

                    Image(systemName: "checkmark")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.5))
                }
                .scaleEffect(scale)
                .opacity(opacity)

                VStack(spacing: 12) {
                    Text("workout.workout_complete".localizedString)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text(motivationalKey.localizedString)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))

                    Text("\(sessionDay) • \(sessionTheme)")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                .opacity(opacity)

                // Enhanced Stats
                HStack(spacing: 16) {
                    StatBadge(
                        icon: "timer",
                        value: formattedTime,
                        label: "workout.total_time".localizedString
                    )
                    StatBadge(
                        icon: "checkmark.circle.fill",
                        value: "\(totalExercises)",
                        label: "workout.stat.exercises".localizedString
                    )
                    StatBadge(
                        icon: "flame.fill",
                        value: "~\(estimatedCalories)",
                        label: "workout.est_calories".localizedString
                    )
                }
                .opacity(opacity)

                // Rate Workout button (primary)
                Button {
                    showFeedback = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "star.fill")
                        Text("workout_feedback.rate_workout".localizedString)
                    }
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.5))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: .white.opacity(0.5), radius: 20, x: 0, y: 10)
                }
                .padding(.horizontal, 40)
                .opacity(opacity)

                // Skip feedback
                Button(action: onDismiss) {
                    Text("workout_feedback.skip".localizedString)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
                .opacity(opacity)

                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showConfetti = true
            }

            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
        .sheet(isPresented: $showFeedback) {
            PostWorkoutFeedbackView(
                sessionDay: sessionDay,
                sessionTheme: sessionTheme,
                totalExercises: totalExercises,
                elapsedSeconds: Int(elapsedTime),
                onDismiss: {
                    showFeedback = false
                    onDismiss()
                }
            )
            .presentationDetents([.fraction(0.85)])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(32)
            .interactiveDismissDisabled(false)
        }
    }
}

// MARK: - Stat Badge
struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(width: 90)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Confetti View
struct ConfettiView: View {
    @State private var opacity: Double = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<50, id: \.self) { index in
                ConfettiPiece(geometry: geometry)
            }
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeOut(duration: 3.0).delay(4.0)) {
                opacity = 0
            }
        }
    }
}

struct ConfettiPiece: View {
    let geometry: GeometryProxy
    @State private var yOffset: CGFloat = 0
    @State private var xOffset: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1
    
    let color: Color = [.red, .blue, .green, .yellow, .purple, .orange, .pink].randomElement() ?? .white
    let size: CGFloat = CGFloat.random(in: 8...16)
    let startX: CGFloat
    let animationDuration: Double = Double.random(in: 2...4)
    let rotationSpeed: Double = Double.random(in: 2...8)
    
    init(geometry: GeometryProxy) {
        self.geometry = geometry
        self.startX = CGFloat.random(in: 0...geometry.size.width)
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: size, height: size)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
            .position(x: startX + xOffset, y: yOffset)
            .onAppear {
                withAnimation(.easeIn(duration: animationDuration)) {
                    yOffset = geometry.size.height + 50
                    xOffset = CGFloat.random(in: -100...100)
                }
                
                withAnimation(.linear(duration: animationDuration).repeatCount(Int(animationDuration * rotationSpeed), autoreverses: false)) {
                    rotation = 360 * rotationSpeed
                }
                
                withAnimation(.easeIn(duration: animationDuration * 0.8).delay(animationDuration * 0.2)) {
                    opacity = 0
                }
            }
    }
}

// MARK: - YouTube Exercise Background
struct YouTubeExerciseBackground: View {
    let thumbnailURL: URL?
    let onPlayTap: () -> Void

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.1, blue: 0.3),
                    Color(red: 0.25, green: 0.15, blue: 0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Thumbnail if available
            if let thumbnailURL = thumbnailURL {
                AsyncImage(url: thumbnailURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .ignoresSafeArea()
                    default:
                        EmptyView()
                    }
                }
            }

            // Dark overlay for better readability
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            // Play button overlay
            VStack(spacing: 20) {
                Button(action: onPlayTap) {
                    ZStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 80, height: 80)
                            .shadow(color: .black.opacity(0.4), radius: 15, x: 0, y: 8)

                        Image(systemName: "play.fill")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .offset(x: 3)
                    }
                }

                VStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "play.rectangle.fill")
                            .font(.system(size: 14, weight: .bold))
                        Text("YouTube")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.red)
                    .clipShape(Capsule())

                    Text("workout.tap_to_watch".localizedString)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }
}

// MARK: - Safari View for YouTube
struct WorkoutSafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        config.barCollapsingEnabled = true

        let safari = SFSafariViewController(url: url, configuration: config)
        safari.dismissButtonStyle = .close

        return safari
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

// MARK: - Inline YouTube Player View (Auto-plays)
/// Embeds a YouTube video using WKWebView that auto-plays inline
/// Falls back to thumbnail with play button if video cannot be embedded
struct InlineYouTubePlayerView: View {
    let videoID: String
    @State private var hasError = false
    @State private var showSafari = false

    private var thumbnailURL: URL? {
        URL(string: "https://img.youtube.com/vi/\(videoID)/hqdefault.jpg")
    }

    private var youtubeWatchURL: URL? {
        URL(string: "https://www.youtube.com/watch?v=\(videoID)")
    }

    var body: some View {
        ZStack {
            if hasError {
                // Fallback: Show thumbnail with play button to open in Safari
                ZStack {
                    AsyncImage(url: thumbnailURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        default:
                            Color.black
                        }
                    }

                    Color.black.opacity(0.4)

                    Button(action: { showSafari = true }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.red)
                                .frame(width: 68, height: 48)
                                .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)

                            Image(systemName: "play.fill")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .offset(x: 2)
                        }
                    }
                }
            } else {
                // Try embedded player
                InlineYouTubeWebViewPlayer(videoID: videoID, hasError: $hasError)
            }
        }
        .fullScreenCover(isPresented: $showSafari) {
            if let url = youtubeWatchURL {
                WorkoutSafariView(url: url)
                    .ignoresSafeArea()
            }
        }
    }
}

/// Internal WebView for YouTube embedding with error detection
private struct InlineYouTubeWebViewPlayer: UIViewRepresentable {
    let videoID: String
    @Binding var hasError: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(hasError: $hasError)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.mediaTypesRequiringUserActionForPlayback = []

        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        webConfiguration.defaultWebpagePreferences = preferences

        // Add message handler for error detection from JavaScript
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "errorHandler")
        webConfiguration.userContentController = contentController

        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .black
        webView.isOpaque = false
        webView.scrollView.backgroundColor = .black
        webView.navigationDelegate = context.coordinator

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // Use youtube-nocookie.com for better privacy and fewer restrictions
        // Add error handling via postMessage API
        let embedHTML = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
                * { margin: 0; padding: 0; }
                html, body {
                    width: 100%;
                    height: 100%;
                    background: #000;
                    overflow: hidden;
                }
                .video-container {
                    position: absolute;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                }
                iframe {
                    position: absolute;
                    top: 50%;
                    left: 50%;
                    width: 177.78vh;
                    height: 100vh;
                    min-width: 100%;
                    min-height: 56.25vw;
                    transform: translate(-50%, -50%);
                    border: none;
                }
                .error-overlay {
                    display: none;
                    position: absolute;
                    top: 0; left: 0; right: 0; bottom: 0;
                    background: #000;
                    color: #fff;
                    justify-content: center;
                    align-items: center;
                    font-family: -apple-system, sans-serif;
                }
            </style>
        </head>
        <body>
            <div class="video-container">
                <iframe id="player"
                    src="https://www.youtube-nocookie.com/embed/\(videoID)?autoplay=1&mute=1&loop=1&playlist=\(videoID)&playsinline=1&controls=0&showinfo=0&rel=0&modestbranding=1&iv_load_policy=3&disablekb=1&enablejsapi=1&origin=https://www.youtube-nocookie.com"
                    allow="autoplay; encrypted-media; picture-in-picture"
                    allowfullscreen>
                </iframe>
            </div>
            <div class="error-overlay" id="errorOverlay">Video unavailable</div>
            <script>
                // Detect iframe load errors
                var iframe = document.getElementById('player');
                iframe.onerror = function() {
                    window.webkit.messageHandlers.errorHandler.postMessage('error');
                };
                // Timeout fallback - if no content loaded after 5s, assume error
                setTimeout(function() {
                    try {
                        // Try to access iframe - will fail if blocked
                        if (!iframe.contentWindow || iframe.contentWindow.length === 0) {
                            window.webkit.messageHandlers.errorHandler.postMessage('timeout');
                        }
                    } catch(e) {
                        window.webkit.messageHandlers.errorHandler.postMessage('blocked');
                    }
                }, 5000);
            </script>
        </body>
        </html>
        """

        webView.loadHTMLString(embedHTML, baseURL: URL(string: "https://www.youtube-nocookie.com"))
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        @Binding var hasError: Bool

        init(hasError: Binding<Bool>) {
            _hasError = hasError
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "errorHandler" {
                DispatchQueue.main.async {
                    self.hasError = true
                }
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            let nsError = error as NSError
            if nsError.code != -999 && nsError.code != 102 {
                DispatchQueue.main.async {
                    self.hasError = true
                }
            }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            let nsError = error as NSError
            if nsError.code != -999 && nsError.code != 102 {
                DispatchQueue.main.async {
                    self.hasError = true
                }
            }
        }
    }
}

// MARK: - YouTube Thumbnail View for Workout (Fallback)
/// Full-screen YouTube thumbnail that fits the frame and opens Safari on tap
struct WorkoutYouTubeThumbnailView: View {
    let videoID: String
    let onTap: () -> Void

    // Use maxresdefault for highest quality, with fallback to hqdefault
    private var thumbnailURL: URL? {
        URL(string: "https://img.youtube.com/vi/\(videoID)/maxresdefault.jpg")
    }

    private var fallbackThumbnailURL: URL? {
        URL(string: "https://img.youtube.com/vi/\(videoID)/hqdefault.jpg")
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Full-screen thumbnail background
                AsyncImage(url: thumbnailURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                    case .failure:
                        // Fallback to lower quality thumbnail
                        AsyncImage(url: fallbackThumbnailURL) { fallbackPhase in
                            switch fallbackPhase {
                            case .success(let fallbackImage):
                                fallbackImage
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .clipped()
                            default:
                                gradientPlaceholder
                            }
                        }
                    case .empty:
                        ZStack {
                            gradientPlaceholder
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(1.2)
                        }
                    @unknown default:
                        gradientPlaceholder
                    }
                }

                // Dark gradient overlay for better text visibility
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.3),
                        Color.black.opacity(0.1),
                        Color.black.opacity(0.5)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Centered play button
                VStack(spacing: 16) {
                    Button(action: onTap) {
                        ZStack {
                            // Red YouTube-style play button
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.red)
                                .frame(width: 80, height: 56)
                                .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)

                            Image(systemName: "play.fill")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                                .offset(x: 2)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())

                    // "Tap to watch" label
                    HStack(spacing: 6) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 12))
                        Text("workout.tap_to_watch".localizedString)
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Capsule())
                }
            }
        }
        .ignoresSafeArea()
    }

    private var gradientPlaceholder: some View {
        LinearGradient(
            colors: [
                Color(red: 0.2, green: 0.15, blue: 0.35),
                Color(red: 0.15, green: 0.1, blue: 0.25)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Preview
#Preview {
    WorkoutSessionReelsView(
        viewModel: WorkoutDetailViewModel(
            session: WorkoutSession(
                id: 1,
                day: "Monday",
                theme: "Upper Body Strength",
                warmup: "5 min dynamic stretching",
                finisher: "5 min cool down stretch",
                exercises: [
                    WorkoutExercise(
                        id: 1,
                        name: "Bench Press",
                        sets: "4 sets",
                        reps: "12 reps",
                        recovery: "90s",
                        video_url: "https://www.youtube.com/watch?v=rT7DgCr-3pg",
                        is_completed: false
                    ),
                    WorkoutExercise(
                        id: 2,
                        name: "Dumbbell Rows",
                        sets: "3 sets",
                        reps: "15 reps",
                        recovery: "60s",
                        video_url: "https://www.youtube.com/watch?v=FWJR5Ve8bnQ",
                        is_completed: false
                    )
                ],
                is_completed: false,
                completion_date: nil
            )
        ),
        onComplete: {}
    )
}
