//
//  WorkoutReelsView.swift
//  FootballApp
//
//  Reels-style scrolling view with Instagram-like stories
//

import SwiftUI

struct WorkoutReelsView: View {
    let sessions: [WorkoutSession]
    @Binding var completedWorkouts: Set<Int> // Track completed workout IDs
    @Binding var completedExercises: Set<Int> // Track completed exercise IDs
    @State private var currentIndex: Int = 0
    @State private var progressValues: [Int: CGFloat] = [:] // Track progress per reel
    @State private var autoAdvanceTimer: Timer?
    
    var allReels: [WorkoutReel] {
        var reels: [WorkoutReel] = []
        
        // Add overview reel
        reels.append(.overview(sessions: sessions, completedCount: completedWorkouts.count))
        
        // Add weekly progress reel
        reels.append(.weeklyProgress(sessions: sessions, completedWorkouts: completedWorkouts))
        
        // Add a reel for each workout session
        for session in sessions {
            reels.append(.workout(session: session, isCompleted: completedWorkouts.contains(session.id)))
        }
        
        // Add completion summary
        reels.append(.completionSummary(sessions: sessions, completedWorkouts: completedWorkouts))
        
        return reels
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Dynamic Darker Background with Movement
                DynamicDarkBackground()
                    .ignoresSafeArea()
                
                // Reels Content
                TabView(selection: $currentIndex) {
                    ForEach(Array(allReels.enumerated()), id: \.offset) { index, reel in
                        WorkoutReelCard(
                            reel: reel,
                            geometry: geometry,
                            completedWorkouts: $completedWorkouts,
                            completedExercises: $completedExercises
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea()
                
                // Instagram-Style Story Progress Bars
                InstagramStoryProgressBars(
                    currentIndex: currentIndex,
                    totalCount: allReels.count,
                    progress: progressValues[currentIndex] ?? 0
                )
                .padding(.top, 60)
                .padding(.horizontal, 12)
                
                // Top Info Overlay
                VStack(spacing: 0) {
                    HStack(alignment: .center, spacing: 12) {
                        // Workout Info
                        HStack(spacing: 12) {
                            // Avatar/Icon
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "667EEA"), Color(hex: "764BA2")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 36, height: 36)
                                
                                Image(systemName: "figure.strengthtraining.functional")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(reelTitle(for: allReels[currentIndex]))
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Workout Plan")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        
                        Spacer()
                        
                        // Counter
                        Text("\(currentIndex + 1)/\(allReels.count)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.3))
                            )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 100)
                    .padding(.bottom, 12)
                }
                .background(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.7),
                            Color.black.opacity(0.5),
                            Color.black.opacity(0.2),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 180)
                    .ignoresSafeArea(edges: .top)
                )
            }
        }
        .onAppear {
            startAutoAdvance()
        }
        .onDisappear {
            stopAutoAdvance()
        }
    }
    
    private func reelTitle(for reel: WorkoutReel) -> String {
        switch reel {
        case .overview:
            return "Weekly Overview"
        case .weeklyProgress:
            return "Progress Tracker"
        case .workout(let session, _):
            return session.day
        case .completionSummary:
            return "Summary"
        }
    }
    
    // Auto-advance functionality (like Instagram stories)
    private func startAutoAdvance() {
        autoAdvanceTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            withAnimation(.linear(duration: 0.05)) {
                let currentProgress = progressValues[currentIndex] ?? 0
                if currentProgress < 1.0 {
                    progressValues[currentIndex] = min(currentProgress + 0.01, 1.0)
                } else {
                    // Move to next reel
                    if currentIndex < allReels.count - 1 {
                        currentIndex += 1
                        progressValues[currentIndex] = 0
                    } else {
                        stopAutoAdvance()
                    }
                }
            }
        }
    }
    
    private func stopAutoAdvance() {
        autoAdvanceTimer?.invalidate()
        autoAdvanceTimer = nil
    }
}

// MARK: - Instagram-Style Story Progress Bars
struct InstagramStoryProgressBars: View {
    let currentIndex: Int
    let totalCount: Int
    let progress: CGFloat
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<totalCount, id: \.self) { index in
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background bar
                        Capsule()
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 3)
                        
                        // Progress bar
                        Capsule()
                            .fill(Color.white)
                            .frame(
                                width: geometry.size.width * progressAmount(for: index),
                                height: 3
                            )
                    }
                }
                .frame(height: 3)
            }
        }
    }
    
    private func progressAmount(for index: Int) -> CGFloat {
        if index < currentIndex {
            return 1.0 // Completed
        } else if index == currentIndex {
            return progress // Current progress
        } else {
            return 0.0 // Not started
        }
    }
}

// MARK: - Dynamic Dark Background with Movement
struct DynamicDarkBackground: View {
    @State private var animationOffset1: CGFloat = 0
    @State private var animationOffset2: CGFloat = 0
    @State private var animationOffset3: CGFloat = 0
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // Base dark gradient
            LinearGradient(
                colors: [
                    Color(hex: "0A0A12"),
                    Color(hex: "0D0D15"),
                    Color(hex: "0F0F1A"),
                    Color(hex: "0A0A12")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated blob 1 (Purple)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "4A3A6B").opacity(0.4),
                            Color(hex: "2D1F45").opacity(0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 300
                    )
                )
                .frame(width: 600, height: 600)
                .blur(radius: 80)
                .offset(x: animationOffset1, y: animationOffset1 * 0.8)
                .rotationEffect(.degrees(rotation))
            
            // Animated blob 2 (Blue)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "1E3A5F").opacity(0.35),
                            Color(hex: "0F1D30").opacity(0.18),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 250
                    )
                )
                .frame(width: 500, height: 500)
                .blur(radius: 70)
                .offset(x: animationOffset2 * -0.7, y: animationOffset2)
                .rotationEffect(.degrees(-rotation * 0.8))
            
            // Animated blob 3 (Dark Purple)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "3D2952").opacity(0.3),
                            Color(hex: "1A0F26").opacity(0.15),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 280
                    )
                )
                .frame(width: 550, height: 550)
                .blur(radius: 90)
                .offset(x: animationOffset3 * 0.5, y: animationOffset3 * -0.9)
                .rotationEffect(.degrees(rotation * 1.2))
            
            // Subtle noise overlay for texture
            Color.white.opacity(0.02)
                .blendMode(.overlay)
            
            // Dark vignette
            RadialGradient(
                colors: [
                    Color.clear,
                    Color.black.opacity(0.3)
                ],
                center: .center,
                startRadius: 100,
                endRadius: 500
            )
        }
        .onAppear {
            // Slow, smooth animations
            withAnimation(.easeInOut(duration: 20).repeatForever(autoreverses: true)) {
                animationOffset1 = 150
            }
            
            withAnimation(.easeInOut(duration: 25).repeatForever(autoreverses: true)) {
                animationOffset2 = -120
            }
            
            withAnimation(.easeInOut(duration: 18).repeatForever(autoreverses: true)) {
                animationOffset3 = 100
            }
            
            withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

// MARK: - Workout Reel Type
enum WorkoutReel: Identifiable {
    case overview(sessions: [WorkoutSession], completedCount: Int)
    case weeklyProgress(sessions: [WorkoutSession], completedWorkouts: Set<Int>)
    case workout(session: WorkoutSession, isCompleted: Bool)
    case completionSummary(sessions: [WorkoutSession], completedWorkouts: Set<Int>)
    
    var id: String {
        switch self {
        case .overview:
            return "overview"
        case .weeklyProgress:
            return "weekly_progress"
        case .workout(let session, _):
            return "workout_\(session.id)"
        case .completionSummary:
            return "completion_summary"
        }
    }
}

// MARK: - Workout Reel Card
struct WorkoutReelCard: View {
    let reel: WorkoutReel
    let geometry: GeometryProxy
    @Binding var completedWorkouts: Set<Int>
    @Binding var completedExercises: Set<Int>
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Darker, more immersive gradient background
            gradientBackground
                .ignoresSafeArea()
            
            // Subtle overlay for depth
            Color.black.opacity(0.2)
                .ignoresSafeArea()
                .blendMode(.multiply)
            
            // Content
            content
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).delay(0.1)) {
                isAnimating = true
            }
        }
        .onDisappear {
            isAnimating = false
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch reel {
        case .overview(let sessions, let completedCount):
            WorkoutOverviewReelContent(
                sessions: sessions,
                completedCount: completedCount,
                isAnimating: isAnimating
            )
        case .weeklyProgress(let sessions, let completedWorkouts):
            WeeklyProgressReelContent(
                sessions: sessions,
                completedWorkouts: completedWorkouts,
                isAnimating: isAnimating
            )
        case .workout(let session, let isCompleted):
            WorkoutSessionReelContent(
                session: session,
                isCompleted: isCompleted,
                completedExercises: $completedExercises,
                completedWorkouts: $completedWorkouts,
                isAnimating: isAnimating
            )
        case .completionSummary(let sessions, let completedWorkouts):
            CompletionSummaryReelContent(
                sessions: sessions,
                completedWorkouts: completedWorkouts,
                isAnimating: isAnimating
            )
        }
    }
    
    private var gradientBackground: some View {
        Group {
            switch reel {
            case .overview:
                LinearGradient(
                    colors: [
                        Color(hex: "1A1625"), // Darker purple
                        Color(hex: "2D1F3D"), // Deep purple
                        Color(hex: "0F0B15")  // Almost black
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .weeklyProgress:
                LinearGradient(
                    colors: [
                        Color(hex: "0F2027"), // Dark blue-gray
                        Color(hex: "203A43"), // Deep teal
                        Color(hex: "0A0E13")  // Almost black
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .workout(_, let isCompleted):
                if isCompleted {
                    LinearGradient(
                        colors: [
                            Color(hex: "0D3B31"), // Dark green
                            Color(hex: "1A5445"), // Forest green
                            Color(hex: "081612")  // Almost black
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    LinearGradient(
                        colors: [
                            Color(hex: "2D1B1F"), // Dark red
                            Color(hex: "3D2529"), // Deep crimson
                            Color(hex: "110A0D")  // Almost black
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            case .completionSummary:
                LinearGradient(
                    colors: [
                        Color(hex: "2A1B2E"), // Dark magenta
                        Color(hex: "3D2742"), // Deep purple-pink
                        Color(hex: "0E080F")  // Almost black
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }
}

// MARK: - Workout Overview Reel Content
struct WorkoutOverviewReelContent: View {
    let sessions: [WorkoutSession]
    let completedCount: Int
    let isAnimating: Bool
    
    var completionPercentage: Double {
        guard !sessions.isEmpty else { return 0 }
        return Double(completedCount) / Double(sessions.count)
    }
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Progress Ring
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 20)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: isAnimating ? completionPercentage : 0)
                    .stroke(
                        Color.white,
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 1.5, dampingFraction: 0.7), value: isAnimating)
                
                VStack(spacing: 8) {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                    
                    Text("\(completedCount)/\(sessions.count)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("COMPLETED")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white.opacity(0.8))
                        .tracking(2)
                }
                .scaleEffect(isAnimating ? 1.0 : 0.5)
                .opacity(isAnimating ? 1 : 0)
            }
            
            // Stats
            VStack(spacing: 16) {
                HStack(spacing: 8) {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundColor(.white.opacity(0.8))
                    Text("Weekly workout plan")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.white.opacity(0.8))
                    Text("\(Int(completionPercentage * 100))% progress this week")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .offset(y: isAnimating ? 0 : 30)
            .opacity(isAnimating ? 1 : 0)
            
            Spacer()
        }
    }
}

// MARK: - Weekly Progress Reel Content
struct WeeklyProgressReelContent: View {
    let sessions: [WorkoutSession]
    let completedWorkouts: Set<Int>
    let isAnimating: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("WEEKLY PROGRESS")
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)
                    .tracking(2)
                    .offset(y: isAnimating ? 0 : -30)
                    .opacity(isAnimating ? 1 : 0)
                
                VStack(spacing: 16) {
                    ForEach(Array(sessions.enumerated()), id: \.element.id) { index, session in
                        WorkoutDayRow(
                            session: session,
                            isCompleted: completedWorkouts.contains(session.id),
                            delay: Double(index) * 0.1,
                            isAnimating: isAnimating
                        )
                    }
                }
            }
            
            Spacer()
        }
    }
}

struct WorkoutDayRow: View {
    let session: WorkoutSession
    let isCompleted: Bool
    let delay: Double
    let isAnimating: Bool
    
    var dayEmoji: String {
        switch session.day.lowercased() {
        case let day where day.contains("monday"): return "1️⃣"
        case let day where day.contains("tuesday"): return "2️⃣"
        case let day where day.contains("wednesday"): return "3️⃣"
        case let day where day.contains("thursday"): return "4️⃣"
        case let day where day.contains("friday"): return "5️⃣"
        case let day where day.contains("saturday"): return "6️⃣"
        case let day where day.contains("sunday"): return "7️⃣"
        default: return "📅"
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Day emoji
            Text(dayEmoji)
                .font(.system(size: 30))
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(session.day)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(session.theme)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            // Status
            ZStack {
                Circle()
                    .fill(isCompleted ? Color.green : Color.white.opacity(0.3))
                    .frame(width: 40, height: 40)
                
                Image(systemName: isCompleted ? "checkmark" : "clock")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white.opacity(0.15))
        )
        .offset(x: isAnimating ? 0 : -50)
        .opacity(isAnimating ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: isAnimating)
    }
}

// MARK: - Workout Session Reel Content
struct WorkoutSessionReelContent: View {
    let session: WorkoutSession
    let isCompleted: Bool
    @Binding var completedExercises: Set<Int>
    @Binding var completedWorkouts: Set<Int>
    let isAnimating: Bool
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                Spacer()
                    .frame(height: 100)
                
                // Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(isCompleted ? Color.green : Color.white.opacity(0.2))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: isCompleted ? "checkmark.circle.fill" : "figure.run")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .opacity(isAnimating ? 1 : 0)
                    
                    Text(session.day.uppercased())
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .offset(y: isAnimating ? 0 : 30)
                        .opacity(isAnimating ? 1 : 0)
                    
                    Text(session.theme)
                        .font(.title3.weight(.medium))
                        .foregroundColor(.white.opacity(0.8))
                        .offset(y: isAnimating ? 0 : 20)
                        .opacity(isAnimating ? 1 : 0)
                }
                
                // Mark as Complete Button
                if !isCompleted {
                    Button(action: {
                        withAnimation {
                            completedWorkouts.insert(session.id)
                            if let exercises = session.exercises {
                                for exercise in exercises {
                                    completedExercises.insert(exercise.id)
                                }
                            }
                        }
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                            Text("Mark Workout Complete")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.green)
                                .shadow(color: .green.opacity(0.5), radius: 15)
                        )
                    }
                    .offset(y: isAnimating ? 0 : 30)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: isAnimating)
                }
                
                // Warmup
                if let warmup = session.warmup {
                    WorkoutSectionCard(
                        title: "WARM-UP",
                        icon: "flame.fill",
                        content: warmup,
                        color: .orange,
                        isAnimating: isAnimating,
                        delay: 0.4
                    )
                }
                
                // Exercises
                if let exercises = session.exercises, !exercises.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "dumbbell.fill")
                                .foregroundColor(.yellow)
                            Text("EXERCISES")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.white.opacity(0.9))
                                .tracking(1)
                        }
                        .offset(y: isAnimating ? 0 : 20)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5), value: isAnimating)
                        
                        ForEach(Array(exercises.enumerated()), id: \.element.id) { index, exercise in
                            ExerciseCard(
                                exercise: exercise,
                                isCompleted: completedExercises.contains(exercise.id),
                                completedExercises: $completedExercises,
                                isAnimating: isAnimating,
                                delay: 0.6 + Double(index) * 0.1
                            )
                        }
                    }
                }
                
                // Finisher
                if let finisher = session.finisher {
                    WorkoutSectionCard(
                        title: "FINISHER",
                        icon: "bolt.fill",
                        content: finisher,
                        color: .red,
                        isAnimating: isAnimating,
                        delay: 0.8
                    )
                }
                
                Spacer()
                    .frame(height: 100)
            }
            .padding(.horizontal, 24)
        }
    }
}

struct WorkoutSectionCard: View {
    let title: String
    let icon: String
    let content: String
    let color: Color
    let isAnimating: Bool
    let delay: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption.weight(.bold))
                    .foregroundColor(.white.opacity(0.9))
                    .tracking(1)
            }
            
            Text(content)
                .font(.body)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.15))
        )
        .offset(y: isAnimating ? 0 : 30)
        .opacity(isAnimating ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: isAnimating)
    }
}

struct ExerciseCard: View {
    let exercise: WorkoutExercise
    let isCompleted: Bool
    @Binding var completedExercises: Set<Int>
    let isAnimating: Bool
    let delay: Double
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: {
                withAnimation {
                    if isCompleted {
                        completedExercises.remove(exercise.id)
                    } else {
                        completedExercises.insert(exercise.id)
                    }
                }
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            }) {
                HStack(spacing: 12) {
                    // Checkbox
                    ZStack {
                        Circle()
                            .fill(isCompleted ? Color.green : Color.white.opacity(0.3))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: isCompleted ? "checkmark" : "circle")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    // Exercise info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.name)
                            .font(.headline)
                            .foregroundColor(.white)
                            .strikethrough(isCompleted)
                        
                        HStack(spacing: 16) {
                            Label(exercise.sets, systemImage: "repeat")
                            Label(exercise.reps, systemImage: "number")
                            Label(exercise.recovery, systemImage: "clock")
                        }
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    // Expand button
                    if exercise.video_url != nil {
                        Image(systemName: "play.circle.fill")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(isCompleted ? Color.green.opacity(0.2) : Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(isCompleted ? Color.green.opacity(0.5) : Color.clear, lineWidth: 2)
                )
        )
        .offset(y: isAnimating ? 0 : 30)
        .opacity(isAnimating ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: isAnimating)
    }
}

// MARK: - Completion Summary Reel Content
struct CompletionSummaryReelContent: View {
    let sessions: [WorkoutSession]
    let completedWorkouts: Set<Int>
    let isAnimating: Bool
    
    var completionPercentage: Double {
        guard !sessions.isEmpty else { return 0 }
        return Double(completedWorkouts.count) / Double(sessions.count)
    }
    
    var totalExercises: Int {
        sessions.reduce(0) { $0 + ($1.exercises?.count ?? 0) }
    }
    
    var motivationalMessage: String {
        switch completionPercentage {
        case 1.0:
            return "🎉 Amazing! All workouts complete!"
        case 0.75...0.99:
            return "💪 Almost there! Keep pushing!"
        case 0.5...0.74:
            return "🔥 Halfway done! You're crushing it!"
        case 0.25...0.49:
            return "💯 Great start! Keep going!"
        case 0.01...0.24:
            return "🚀 Every journey starts with a step!"
        default:
            return "👟 Time to get started!"
        }
    }
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 24) {
                // Trophy/Star icon
                Image(systemName: completionPercentage >= 1.0 ? "trophy.fill" : "star.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.yellow)
                    .shadow(color: .yellow.opacity(0.5), radius: 20)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .opacity(isAnimating ? 1 : 0)
                
                // Completion percentage
                Text("\(Int(completionPercentage * 100))%")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 10)
                    .offset(y: isAnimating ? 0 : 50)
                    .opacity(isAnimating ? 1 : 0)
                
                Text("WEEK COMPLETE")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.white.opacity(0.9))
                    .tracking(2)
                    .offset(y: isAnimating ? 0 : 30)
                    .opacity(isAnimating ? 1 : 0)
                
                // Motivational message
                Text(motivationalMessage)
                    .font(.title3.weight(.medium))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .offset(y: isAnimating ? 0 : 30)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: isAnimating)
            }
            
            // Stats
            VStack(spacing: 16) {
                StatRow(
                    icon: "checkmark.circle.fill",
                    label: "Workouts completed",
                    value: "\(completedWorkouts.count)/\(sessions.count)",
                    color: .green,
                    isAnimating: isAnimating,
                    delay: 0.4
                )
                
                StatRow(
                    icon: "flame.fill",
                    label: "Total exercises",
                    value: "\(totalExercises)",
                    color: .orange,
                    isAnimating: isAnimating,
                    delay: 0.5
                )
                
                StatRow(
                    icon: "calendar",
                    label: "Days this week",
                    value: "\(sessions.count)",
                    color: .blue,
                    isAnimating: isAnimating,
                    delay: 0.6
                )
            }
            
            Spacer()
        }
    }
}

struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    let isAnimating: Bool
    let delay: Double
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.white.opacity(0.15))
        )
        .offset(x: isAnimating ? 0 : -50)
        .opacity(isAnimating ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: isAnimating)
    }
}

#Preview {
    WorkoutReelsView(
        sessions: [
            WorkoutSession(
                id: 1,
                day: "Monday",
                theme: "Strength Training",
                warmup: "5 min jog",
                finisher: "Stretching",
                exercises: [
                    WorkoutExercise(id: 1, name: "Push-ups", sets: "3", reps: "15", recovery: "60s", video_url: nil, is_completed: false),
                    WorkoutExercise(id: 2, name: "Squats", sets: "3", reps: "20", recovery: "90s", video_url: nil, is_completed: false)
                ],
                is_completed: false,
                completion_date: nil
            )
        ],
        completedWorkouts: .constant([]),
        completedExercises: .constant([])
    )
}

// MARK: - Workout Reels Wrapper
struct WorkoutReelsViewWrapper: View {
    let sessions: [WorkoutSession]
    @Binding var completedWorkouts: Set<Int>
    @Binding var completedExercises: Set<Int>
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            WorkoutReelsView(
                sessions: sessions,
                completedWorkouts: $completedWorkouts,
                completedExercises: $completedExercises
            )
            
            // Close Button
            Button(action: {
                withAnimation {
                    isPresented = false
                }
            }) {
                Image(systemName: "xmark")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.3), radius: 10)
                    )
            }
            .padding(.top, 60)
            .padding(.trailing, 20)
        }
    }
}
