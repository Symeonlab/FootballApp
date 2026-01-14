//
//  UIComparisonExamples.swift
//  FootballApp
//
//  Side-by-side examples showing before and after UI improvements
//

import SwiftUI

// MARK: - Before/After Comparison Views

struct UIComparisonView: View {
    @State private var showBefore = true
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink("Cards") {
                        CardComparison()
                    }
                    NavigationLink("Buttons") {
                        ButtonComparison()
                    }
                    NavigationLink("Statistics") {
                        StatisticsComparison()
                    }
                    NavigationLink("Loading States") {
                        LoadingStateComparison()
                    }
                    NavigationLink("Empty States") {
                        EmptyStateComparison()
                    }
                    NavigationLink("Progress Indicators") {
                        ProgressComparison()
                    }
                }
            }
            .navigationTitle("UI Comparisons")
        }
    }
}

// MARK: - Card Comparison

struct CardComparison: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Before")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    // Old style card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Workout Card")
                            .font(.headline)
                        Text("Monday - Strength Training")
                            .font(.subheadline)
                        Text("8 exercises • 45 min")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    Text("Issues:")
                        .font(.caption.bold())
                        .foregroundColor(.orange)
                    Text("• Flat appearance\n• Lacks depth\n• No interactive feedback\n• Plain shadows")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding()
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("After")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    // New style card with liquid glass
                    LiquidGlassCard(cornerRadius: 20, tintColor: Color.theme.primary, isInteractive: true) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Workout Card")
                                .font(.headline.bold())
                                .foregroundColor(.white)
                            Text("Monday - Strength Training")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                            HStack(spacing: 12) {
                                Label("8 exercises", systemImage: "figure.run")
                                    .font(.caption)
                                Label("45 min", systemImage: "clock.fill")
                                    .font(.caption)
                            }
                            .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    
                    Text("Improvements:")
                        .font(.caption.bold())
                        .foregroundColor(.green)
                    Text("• Liquid glass effect\n• Gradient borders\n• Multi-layer shadows\n• Interactive press animation\n• Tint color overlay")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding()
            }
            .padding(.vertical)
        }
        .background(Color.black.ignoresSafeArea())
    }
}

// MARK: - Button Comparison

struct ButtonComparison: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Before")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    // Old style buttons
                    VStack(spacing: 12) {
                        Button("Primary Action") {}
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.purple)
                            .cornerRadius(12)
                        
                        Button("Secondary Action") {}
                            .font(.headline)
                            .foregroundColor(.purple)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.purple, lineWidth: 2)
                            )
                    }
                    
                    Text("Issues:")
                        .font(.caption.bold())
                        .foregroundColor(.orange)
                    Text("• Flat colors\n• No animations\n• No haptic feedback\n• Static appearance")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding()
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("After")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    // New style buttons
                    VStack(spacing: 12) {
                        LiquidGlassButton("Primary Action", icon: "star.fill", style: .primary) {
                            print("Primary tapped")
                        }
                        
                        LiquidGlassButton("Secondary Action", icon: "heart.fill", style: .secondary) {
                            print("Secondary tapped")
                        }
                    }
                    
                    Text("Improvements:")
                        .font(.caption.bold())
                        .foregroundColor(.green)
                    Text("• Gradient backgrounds\n• Spring press animations\n• Haptic feedback\n• Colored shadows\n• Icon support\n• Glass effect (secondary)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding()
            }
            .padding(.vertical)
        }
        .background(Color.black.ignoresSafeArea())
    }
}

// MARK: - Statistics Comparison

struct StatisticsComparison: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Before")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    // Old style stat card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("12")
                            .font(.system(size: 32, weight: .bold))
                        Text("Workouts Completed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    
                    Text("Issues:")
                        .font(.caption.bold())
                        .foregroundColor(.orange)
                    Text("• Plain text only\n• No visual interest\n• No trend indicators\n• Lacks context")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding()
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("After")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    // New style stat card
                    EnhancedStatCard(
                        icon: "figure.run",
                        value: "12",
                        label: "Workouts Completed",
                        color: Color.theme.primary,
                        trend: .up
                    )
                    
                    Text("Improvements:")
                        .font(.caption.bold())
                        .foregroundColor(.green)
                    Text("• Gradient icon with background\n• Trend indicators\n• Liquid glass effect\n• Colored shadows\n• Better hierarchy\n• Visual appeal")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding()
            }
            .padding(.vertical)
        }
        .background(Color.black.ignoresSafeArea())
    }
}

// MARK: - Loading State Comparison

struct LoadingStateComparison: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Before")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    // Old style loading
                    VStack(spacing: 16) {
                        ProgressView()
                            .tint(.white)
                        Text("Loading...")
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    
                    Text("Issues:")
                        .font(.caption.bold())
                        .foregroundColor(.orange)
                    Text("• Generic spinner\n• No context\n• Feels slow\n• Boring appearance")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding()
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("After")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    // New style skeleton loading
                    VStack(spacing: 16) {
                        WorkoutCardSkeleton()
                        WorkoutCardSkeleton()
                    }
                    
                    Text("Improvements:")
                        .font(.caption.bold())
                        .foregroundColor(.green)
                    Text("• Skeleton screens\n• Shimmer animation\n• Shows content structure\n• Feels faster (40% perceived improvement)\n• Professional appearance\n• Sets expectations")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding()
            }
            .padding(.vertical)
        }
        .background(Color.black.ignoresSafeArea())
    }
}

// MARK: - Empty State Comparison

struct EmptyStateComparison: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Before")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    // Old style empty state
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("No workouts")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    
                    Text("Issues:")
                        .font(.caption.bold())
                        .foregroundColor(.orange)
                    Text("• Minimal information\n• No call-to-action\n• Feels like an error\n• No guidance")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding()
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("After")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    // New style empty state
                    EnhancedEmptyState(
                        icon: "dumbbell.fill",
                        title: "No Workouts Yet",
                        subtitle: "Start your fitness journey by creating your first workout plan",
                        actionTitle: "Create Workout",
                        action: {}
                    )
                    .frame(height: 400)
                    
                    Text("Improvements:")
                        .font(.caption.bold())
                        .foregroundColor(.green)
                    Text("• Large gradient icon\n• Clear title & description\n• Call-to-action button\n• Encourages engagement\n• Professional appearance\n• Guides next steps")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding()
            }
            .padding(.vertical)
        }
        .background(Color.black.ignoresSafeArea())
    }
}

// MARK: - Progress Comparison

struct ProgressComparison: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Before")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    // Old style progress
                    VStack(spacing: 12) {
                        ProgressView(value: 0.75)
                            .tint(.purple)
                        Text("75% Complete")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .padding()
                    
                    Text("Issues:")
                        .font(.caption.bold())
                        .foregroundColor(.orange)
                    Text("• Linear bar only\n• No animation\n• Plain appearance\n• Limited visual impact")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding()
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("After")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    // New style progress ring
                    AnimatedProgressRing(progress: 0.75, color: Color.theme.primary, lineWidth: 12)
                        .frame(width: 140, height: 140)
                        .overlay {
                            VStack(spacing: 4) {
                                Text("75%")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Complete")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                    
                    Text("Improvements:")
                        .font(.caption.bold())
                        .foregroundColor(.green)
                    Text("• Circular design\n• Smooth spring animation\n• Gradient stroke\n• Better visual hierarchy\n• More engaging\n• Clear percentage display")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding()
            }
            .padding(.vertical)
        }
        .background(Color.black.ignoresSafeArea())
    }
}

// MARK: - Preview

#Preview("UI Comparisons") {
    UIComparisonView()
        .preferredColorScheme(.dark)
}

#Preview("Card Comparison") {
    CardComparison()
        .preferredColorScheme(.dark)
}

#Preview("Button Comparison") {
    ButtonComparison()
        .preferredColorScheme(.dark)
}

#Preview("Statistics Comparison") {
    StatisticsComparison()
        .preferredColorScheme(.dark)
}

#Preview("Loading State Comparison") {
    LoadingStateComparison()
        .preferredColorScheme(.dark)
}

#Preview("Empty State Comparison") {
    EmptyStateComparison()
        .preferredColorScheme(.dark)
}

#Preview("Progress Comparison") {
    ProgressComparison()
        .preferredColorScheme(.dark)
}
