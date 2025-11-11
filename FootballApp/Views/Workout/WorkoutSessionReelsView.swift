//
//  WorkoutSessionReelsView.swift
//  FootballApp
//
//  Full-screen workout experience with exercise reels
//

import SwiftUI
import AVKit

struct WorkoutSessionReelsView: View {
    @ObservedObject var viewModel: WorkoutDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var currentPhase: WorkoutPhase = .intro
    @State private var currentExerciseIndex: Int = 0
    @State private var showingRestTimer = false
    
    var onComplete: () -> Void
    
    private enum WorkoutPhase {
        case intro, warmup, exercises, cooldown, completion
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            // Phase-based content
            Group {
                switch currentPhase {
                case .intro:
                    WorkoutIntroReelView(
                        session: viewModel.session,
                        onStart: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                if viewModel.session.warmup != nil {
                                    currentPhase = .warmup
                                } else {
                                    currentPhase = .exercises
                                }
                            }
                        }
                    )
                    .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .leading).combined(with: .opacity)))
                
                case .warmup:
                    WarmupReelView(
                        warmupDescription: viewModel.session.warmup ?? "",
                        onComplete: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                currentPhase = .exercises
                            }
                        },
                        onSkip: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                currentPhase = .exercises
                            }
                        }
                    )
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
                
                case .exercises:
                    if showingRestTimer {
                        RestTimerReelView(
                            restTime: viewModel.timerValue,
                            totalRestTime: viewModel.totalTime,
                            nextExercise: viewModel.nextExercise,
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
                                
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    showingRestTimer = true
                                }
                            },
                            onCompleteExercise: {
                                if currentExerciseIndex < (viewModel.session.exercises?.count ?? 0) - 1 {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        currentExerciseIndex += 1
                                        viewModel.currentExerciseIndex = currentExerciseIndex
                                        viewModel.currentSet = 1
                                    }
                                } else {
                                    // All exercises complete
                                    if viewModel.session.finisher != nil {
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
                            onSkip: { }
                        )
                        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .scale.combined(with: .opacity)))
                    }
                
                case .cooldown:
                    CooldownReelView(
                        cooldownDescription: viewModel.session.finisher ?? "",
                        onComplete: {
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
                        sessionTheme: viewModel.session.theme,
                        totalExercises: viewModel.totalExercisesInSession,
                        onDismiss: {
                            onComplete()
                            dismiss()
                        }
                    )
                    .transition(.asymmetric(insertion: .scale(scale: 0.8).combined(with: .opacity), removal: .opacity))
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentPhase)
            
            // Close button overlay (not shown during intro or completion)
            if currentPhase != .intro && currentPhase != .completion {
                VStack {
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.title3.weight(.semibold))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        .padding()
                        
                        Spacer()
                        
                        // Phase indicator
                        if currentPhase == .exercises && !showingRestTimer {
                            HStack(spacing: 6) {
                                Image(systemName: "figure.run")
                                    .font(.caption.weight(.semibold))
                                Text("\(currentExerciseIndex + 1)/\(viewModel.totalExercisesInSession)")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Capsule())
                            .padding()
                        }
                    }
                    
                    Spacer()
                }
            }
        }
        .preferredColorScheme(.dark)
        .statusBar(hidden: true)
    }
}

// MARK: - Workout Intro Reel
struct WorkoutIntroReelView: View {
    let session: WorkoutSession
    let onStart: () -> Void
    
    @State private var scaleEffect: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            // Dynamic gradient based on theme
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated particles
            ParticleFieldView()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Day badge
                Text(session.day.uppercased())
                    .font(.system(size: 16, weight: .bold))
                    .tracking(2)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                    )
                    .scaleEffect(scaleEffect)
                    .opacity(opacity)
                
                // Theme title
                VStack(spacing: 12) {
                    Image(systemName: themeIcon)
                        .font(.system(size: 60, weight: .light))
                        .foregroundColor(.white)
                    
                    Text(session.theme)
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .scaleEffect(scaleEffect)
                .opacity(opacity)
                
                // Session info
                VStack(spacing: 16) {
                    if let exercises = session.exercises {
                        InfoRow(icon: "dumbbell.fill", text: "\(exercises.count) Exercises", color: .white)
                    }
                    if let warmup = session.warmup {
                        InfoRow(icon: "flame.fill", text: "Warmup: \(warmup)", color: .orange)
                    }
                    if let finisher = session.finisher {
                        InfoRow(icon: "bolt.fill", text: "Finisher: \(finisher)", color: .yellow)
                    }
                }
                .scaleEffect(scaleEffect)
                .opacity(opacity)
                
                // Start button
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    onStart()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "play.fill")
                            .font(.title3.bold())
                        Text("Start Workout")
                            .font(.system(size: 20, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
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
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: Color(red: 0.5, green: 0.4, blue: 1.0).opacity(0.6), radius: 25, x: 0, y: 10)
                }
                .padding(.horizontal, 32)
                .scaleEffect(scaleEffect)
                .opacity(opacity)
                
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.1)) {
                scaleEffect = 1.0
                opacity = 1.0
            }
        }
    }
    
    private var gradientColors: [Color] {
        let theme = session.theme.lowercased()
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
    
    private var themeIcon: String {
        let theme = session.theme.lowercased()
        if theme.contains("force") || theme.contains("strength") {
            return "dumbbell.fill"
        } else if theme.contains("cardio") || theme.contains("endurance") {
            return "figure.run"
        } else if theme.contains("vitesse") || theme.contains("speed") {
            return "bolt.fill"
        } else if theme.contains("flexibility") || theme.contains("mobility") {
            return "figure.flexibility"
        } else {
            return "figure.strengthtraining.functional"
        }
    }
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
    
    @State private var progress: Double = 0
    @State private var scaleEffect: CGFloat = 0.8
    @State private var timer: Timer?
    
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
                
                // Flame icon
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 140, height: 140)
                        .scaleEffect(1.0 + (progress * 0.2))
                    
                    Image(systemName: "flame.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.white)
                        .shadow(color: .white.opacity(0.5), radius: 20)
                }
                .scaleEffect(scaleEffect)
                
                VStack(spacing: 16) {
                    Text("WARMUP")
                        .font(.system(size: 22, weight: .bold))
                        .tracking(3)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text(warmupDescription)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.2))
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .frame(width: geometry.size.width * progress)
                    }
                }
                .frame(height: 8)
                .padding(.horizontal, 40)
                
                // Action buttons
                HStack(spacing: 16) {
                    Button(action: onSkip) {
                        Text("Skip")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    Button(action: onComplete) {
                        Text("Ready!")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.3))
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
            
            // Start progress animation
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                withAnimation(.linear(duration: 0.1)) {
                    if progress < 1.0 {
                        progress += 0.01
                    } else {
                        timer?.invalidate()
                        onComplete()
                    }
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
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
    let onComplete: () -> Void
    let onSkip: () -> Void
    
    var progress: Double {
        guard totalRestTime > 0 else { return 0 }
        return Double(totalRestTime - restTime) / Double(totalRestTime)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.2, green: 0.3, blue: 0.5), Color(red: 0.15, green: 0.2, blue: 0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Timer circle
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 12)
                        .frame(width: 200, height: 200)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1.0), value: progress)
                    
                    VStack(spacing: 8) {
                        Text("REST")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                            .tracking(2)
                        
                        Text("\(restTime)")
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("seconds")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                // Next exercise preview
                if let next = nextExercise {
                    VStack(spacing: 12) {
                        Text("UP NEXT")
                            .font(.caption.weight(.bold))
                            .tracking(2)
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text(next.name)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 40)
                }
                
                // Skip button
                Button(action: onSkip) {
                    Text("Skip Rest")
                        .font(.system(size: 16, weight: .semibold))
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
}

// MARK: - Cooldown Reel View
struct CooldownReelView: View {
    let cooldownDescription: String
    let onComplete: () -> Void
    let onSkip: () -> Void
    
    @State private var progress: Double = 0
    @State private var scaleEffect: CGFloat = 0.8
    @State private var timer: Timer?
    
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
                
                // Cooldown icon
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 140, height: 140)
                        .scaleEffect(1.0 + (progress * 0.2))
                    
                    Image(systemName: "figure.cooldown")
                        .font(.system(size: 70))
                        .foregroundColor(.white)
                        .shadow(color: .white.opacity(0.5), radius: 20)
                }
                .scaleEffect(scaleEffect)
                
                VStack(spacing: 16) {
                    Text("COOLDOWN")
                        .font(.system(size: 22, weight: .bold))
                        .tracking(3)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text(cooldownDescription)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.2))
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .frame(width: geometry.size.width * progress)
                    }
                }
                .frame(height: 8)
                .padding(.horizontal, 40)
                
                // Action buttons
                HStack(spacing: 16) {
                    Button(action: onSkip) {
                        Text("Skip")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    Button(action: onComplete) {
                        Text("Done!")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.3))
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
            
            // Start progress animation
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                withAnimation(.linear(duration: 0.1)) {
                    if progress < 1.0 {
                        progress += 0.01
                    } else {
                        timer?.invalidate()
                        onComplete()
                    }
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
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
    
    @State private var showVideo = false
    
    var body: some View {
        ZStack {
            // Video or image background
            if let videoURL = exercise.video_url, let url = URL(string: videoURL) {
                VideoPlayerView(url: url)
                    .ignoresSafeArea()
            } else {
                // Gradient placeholder
                LinearGradient(
                    colors: [
                        Color(red: 0.2, green: 0.15, blue: 0.35),
                        Color(red: 0.15, green: 0.1, blue: 0.25)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay {
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white.opacity(0.2))
                }
            }
            
            // Content overlay
            VStack {
                Spacer()
                
                // Exercise info card
                VStack(alignment: .leading, spacing: 16) {
                    // Exercise number badge
                    HStack {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color(red: 0.6, green: 0.4, blue: 1.0))
                                .frame(width: 8, height: 8)
                            Text("Exercise \(exerciseNumber) of \(totalExercises)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.4))
                        .clipShape(Capsule())
                        
                        Spacer()
                    }
                    
                    // Exercise name
                    Text(exercise.name)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    // Exercise details
                    HStack(spacing: 16) {
                        DetailPill(icon: "repeat", text: exercise.reps, color: Color(red: 0.4, green: 0.8, blue: 0.6))
                        DetailPill(icon: "square.stack.3d.up", text: exercise.sets, color: Color(red: 0.6, green: 0.4, blue: 1.0))
                        DetailPill(icon: "timer", text: exercise.recovery, color: Color(red: 1.0, green: 0.6, blue: 0.3))
                    }
                    
                    // Current set indicator
                    HStack(spacing: 8) {
                        Text("Set:")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        
                        ForEach(1...totalSets, id: \.self) { set in
                            Circle()
                                .fill(set <= currentSet ? Color(red: 0.6, green: 0.4, blue: 1.0) : Color.white.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    // Action buttons
                    HStack(spacing: 12) {
                        Button(action: onSkip) {
                            Text("Skip")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.white.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        Button(action: onComplete) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .bold))
                                Text("Complete Set")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
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
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: Color(red: 0.5, green: 0.4, blue: 1.0).opacity(0.5), radius: 12, x: 0, y: 6)
                        }
                    }
                    
                    // Watch video button
                    if exercise.video_url != nil {
                        Button(action: {
                            showVideo = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "play.circle.fill")
                                Text("Watch Tutorial")
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .padding()
            }
        }
        .fullScreenCover(isPresented: $showVideo) {
            if let videoURL = exercise.video_url, let url = URL(string: videoURL) {
                VideoPlayerFullScreen(url: url)
            }
        }
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
    let onDismiss: () -> Void
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var showConfetti = false
    
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
            
            VStack(spacing: 40) {
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
                
                VStack(spacing: 16) {
                    Text("Workout Complete!")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("\(sessionDay) • \(sessionTheme)")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text("\(totalExercises) exercises completed")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                }
                .opacity(opacity)
                
                // Stats
                HStack(spacing: 24) {
                    StatBadge(icon: "checkmark.circle.fill", value: "\(totalExercises)", label: "Exercises")
                    StatBadge(icon: "flame.fill", value: "100%", label: "Effort")
                    StatBadge(icon: "star.fill", value: "Great", label: "Performance")
                }
                .opacity(opacity)
                
                Button(action: onDismiss) {
                    Text("Done")
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
            withAnimation(.easeOut(duration: 3.0).delay(2.0)) {
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
                        video_url: nil,
                        is_completed: false
                    ),
                    WorkoutExercise(
                        id: 2,
                        name: "Dumbbell Rows",
                        sets: "3 sets",
                        reps: "15 reps",
                        recovery: "60s",
                        video_url: nil,
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
