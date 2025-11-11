//
//  ActivityDashboardView.swift
//  FootballApp
//
//  Modern activity tracking with iOS 17+ features
//

import SwiftUI
import Combine

fileprivate struct ADHealthData {
    var steps: Int?
    var activeCalories: Int?
    var exerciseMinutes: Int?
    var distance: Double?
    var heartRate: Int?
}

struct ActivityDashboardView: View {
    @StateObject private var viewModel = ActivityDashboardViewModel()
    @State private var selectedPeriod: TimePeriod = .today
    @Namespace private var periodNamespace
    
    enum TimePeriod: String, CaseIterable, Identifiable {
        case today = "Today"
        case week = "Week"
        case month = "Month"
        
        var id: String { rawValue }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Mesh background
                Color.appTheme.meshGradient
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 20) {
                        // Period Selector
                        PeriodSelector(
                            selectedPeriod: $selectedPeriod,
                            namespace: periodNamespace
                        )
                        .padding(.horizontal, 20)
                        
                        // Activity Rings (Today only)
                        if selectedPeriod == .today {
                            ModernActivityRings(healthData: ADHealthData(
                                steps: viewModel.healthData.steps,
                                activeCalories: viewModel.healthData.activeCalories,
                                exerciseMinutes: viewModel.healthData.exerciseMinutes,
                                distance: viewModel.healthData.distance,
                                heartRate: viewModel.healthData.heartRate
                            ))
                            .padding(.horizontal, 20)
                        }
                        
                        // Stats Grid
                        StatsGridView(healthData: ADHealthData(
                            steps: viewModel.healthData.steps,
                            activeCalories: viewModel.healthData.activeCalories,
                            exerciseMinutes: viewModel.healthData.exerciseMinutes,
                            distance: viewModel.healthData.distance,
                            heartRate: viewModel.healthData.heartRate
                        ))
                        .padding(.horizontal, 20)
                        
                        // Activity Chart
                        ActivityChartView(period: selectedPeriod)
                            .padding(.horizontal, 20)
                        
                        // Quick Actions
                        QuickActionsView()
                            .padding(.horizontal, 20)
                        
                        // Recent Activity
                        RecentActivityView()
                            .padding(.horizontal, 20)
                        
                        // Bottom spacing
                        Color.clear.frame(height: 120)
                    }
                    .padding(.top, 12)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Activity")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .onAppear {
                viewModel.fetchHealthData()
            }
            .refreshable {
                await withCheckedContinuation { continuation in
                    viewModel.fetchHealthData()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        continuation.resume()
                    }
                }
            }
        }
    }
}

// MARK: - Period Selector
struct PeriodSelector: View {
    @Binding var selectedPeriod: ActivityDashboardView.TimePeriod
    var namespace: Namespace.ID
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(ActivityDashboardView.TimePeriod.allCases) { period in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selectedPeriod = period
                    }
                } label: {
                    Text(period.rawValue)
                        .font(.subheadline.weight(selectedPeriod == period ? .semibold : .medium))
                        .foregroundColor(selectedPeriod == period ? .white : Color.appTheme.textSecondary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background {
                            if selectedPeriod == period {
                                Capsule()
                                    .fill(Color.appTheme.primaryGradient)
                                    .matchedGeometryEffect(id: "periodSelector", in: namespace)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background {
            Capsule()
                .fill(Color.appTheme.surface)
        }
    }
}

// MARK: - Modern Activity Rings
fileprivate struct ModernActivityRings: View {
    let healthData: ADHealthData
    
    var moveProgress: Double {
        guard let calories = healthData.activeCalories else { return 0 }
        return min(Double(calories) / 500.0, 1.0)
    }
    
    var exerciseProgress: Double {
        guard let minutes = healthData.exerciseMinutes else { return 0 }
        return min(Double(minutes) / 30.0, 1.0)
    }
    
    var standProgress: Double {
        guard let steps = healthData.steps else { return 0 }
        return min(Double(steps) / 10000.0, 1.0)
    }
    
    @State private var animateRings = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Today's Progress")
                    .font(.headline.bold())
                    .foregroundColor(Color.appTheme.textPrimary)
                
                Spacer()
                
                Text("\(Int((moveProgress + exerciseProgress + standProgress) / 3 * 100))%")
                    .font(.headline.bold())
                    .foregroundStyle(Color.appTheme.primaryGradient)
            }
            
            HStack(spacing: 32) {
                // Move Ring
                ActivityRingItem(
                    progress: animateRings ? moveProgress : 0,
                    color: .red,
                    icon: "flame.fill",
                    value: "\(healthData.activeCalories ?? 0)",
                    label: "CAL",
                    goal: "500"
                )
                
                // Exercise Ring
                ActivityRingItem(
                    progress: animateRings ? exerciseProgress : 0,
                    color: .green,
                    icon: "figure.run",
                    value: "\(healthData.exerciseMinutes ?? 0)",
                    label: "MIN",
                    goal: "30"
                )
                
                // Stand Ring
                ActivityRingItem(
                    progress: animateRings ? standProgress : 0,
                    color: .blue,
                    icon: "figure.walk",
                    value: formatSteps(healthData.steps ?? 0),
                    label: "STEPS",
                    goal: "10K"
                )
            }
        }
        .padding(24)
        .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.appTheme.surface)
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.15), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
        }
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8).delay(0.3)) {
                animateRings = true
            }
        }
    }
    
    private func formatSteps(_ steps: Int) -> String {
        if steps >= 1000 {
            return String(format: "%.1fK", Double(steps) / 1000.0)
        }
        return "\(steps)"
    }
}

struct ActivityRingItem: View {
    let progress: Double
    let color: Color
    let icon: String
    let value: String
    let label: String
    let goal: String
    
    var body: some View {
        VStack(spacing: 12) {
            // Ring
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 10)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        color,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: color.opacity(0.5), radius: 4, x: 0, y: 2)
                    .animation(.spring(response: 0.8, dampingFraction: 0.8), value: progress)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            
            // Stats
            VStack(spacing: 4) {
                Text(value)
                    .font(.headline.bold())
                    .foregroundColor(Color.appTheme.textPrimary)
                    .contentTransition(.numericText())
                
                Text(label)
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(Color.appTheme.textSecondary)
                
                Text("of \(goal)")
                    .font(.caption2)
                    .foregroundColor(Color.appTheme.textTertiary)
            }
        }
    }
}

// MARK: - Stats Grid
fileprivate struct StatsGridView: View {
    let healthData: ADHealthData
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCardView(
                icon: "figure.walk",
                title: "Steps",
                value: healthData.steps != nil ? "\(healthData.steps!)" : "—",
                color: .blue,
                trend: "+12%",
                trendUp: true
            )
            
            StatCardView(
                icon: "flame.fill",
                title: "Calories",
                value: healthData.activeCalories != nil ? "\(healthData.activeCalories!)" : "—",
                color: .orange,
                trend: "+8%",
                trendUp: true
            )
            
            StatCardView(
                icon: "map",
                title: "Distance",
                value: healthData.distance != nil ? String(format: "%.1f km", healthData.distance!) : "—",
                color: .green,
                trend: "+5%",
                trendUp: true
            )
            
            StatCardView(
                icon: "heart.fill",
                title: "Heart Rate",
                value: healthData.heartRate != nil ? "\(healthData.heartRate!) bpm" : "—",
                color: .red,
                trend: nil,
                trendUp: nil
            )
        }
    }
}

struct StatCardView: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let trend: String?
    let trendUp: Bool?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Spacer()
                
                if let trend = trend, let trendUp = trendUp {
                    HStack(spacing: 4) {
                        Image(systemName: trendUp ? "arrow.up.right" : "arrow.down.right")
                            .font(.caption2)
                        Text(trend)
                            .font(.caption.bold())
                    }
                    .foregroundColor(trendUp ? .green : .red)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2.bold())
                    .foregroundColor(Color.appTheme.textPrimary)
                    .contentTransition(.numericText())
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(Color.appTheme.textSecondary)
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.appTheme.surface)
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                }
        }
        .shadow(color: color.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Activity Chart
struct ActivityChartView: View {
    let period: ActivityDashboardView.TimePeriod
    
    // Mock data for visualization
    private let weekData: [CGFloat] = [0.6, 0.8, 0.5, 0.9, 0.7, 0.85, 0.65]
    private let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]
    
    @State private var animateChart = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Activity Trend")
                    .font(.headline.bold())
                    .foregroundColor(Color.appTheme.textPrimary)
                
                Spacer()
                
                Text("This Week")
                    .font(.caption)
                    .foregroundColor(Color.appTheme.textSecondary)
            }
            
            // Bar chart
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(weekData.enumerated()), id: \.offset) { index, value in
                    VStack(spacing: 8) {
                        // Bar
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(
                                index == Calendar.current.component(.weekday, from: Date()) - 2
                                    ? Color.appTheme.primaryGradient
                                    : LinearGradient(colors: [Color.appTheme.surface], startPoint: .top, endPoint: .bottom)
                            )
                            .frame(height: animateChart ? 120 * value : 0)
                            .animation(
                                .spring(response: 0.6, dampingFraction: 0.8)
                                    .delay(Double(index) * 0.05),
                                value: animateChart
                            )
                        
                        // Label
                        Text(dayLabels[index])
                            .font(.caption2.weight(.medium))
                            .foregroundColor(
                                index == Calendar.current.component(.weekday, from: Date()) - 2
                                    ? Color.appTheme.primary
                                    : Color.appTheme.textSecondary
                            )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 150)
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.appTheme.surface)
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                }
        }
        .onAppear {
            withAnimation {
                animateChart = true
            }
        }
    }
}

// MARK: - Quick Actions
struct QuickActionsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline.bold())
                .foregroundColor(Color.appTheme.textPrimary)
            
            HStack(spacing: 12) {
                ActivityQuickActionButton(
                    icon: "plus.circle.fill",
                    title: "Log Workout",
                    color: .blue
                ) {
                    // Action
                }
                
                ActivityQuickActionButton(
                    icon: "chart.bar.fill",
                    title: "View Stats",
                    color: .purple
                ) {
                    // Action
                }
                
                ActivityQuickActionButton(
                    icon: "heart.text.square.fill",
                    title: "Health App",
                    color: .red
                ) {
                    if let url = URL(string: "x-apple-health://") {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.appTheme.surface)
        }
    }
}

fileprivate struct ActivityQuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Color.appTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(color.opacity(0.1))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(color.opacity(0.2), lineWidth: 1)
                    }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Recent Activity
struct RecentActivityView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.headline.bold())
                .foregroundColor(Color.appTheme.textPrimary)
            
            VStack(spacing: 12) {
                RecentActivityRow(
                    icon: "figure.soccer",
                    title: "Football Training",
                    time: "45 min",
                    calories: "320 cal",
                    date: "Today",
                    color: .green
                )
                
                RecentActivityRow(
                    icon: "figure.strengthtraining.traditional",
                    title: "Strength Training",
                    time: "30 min",
                    calories: "250 cal",
                    date: "Yesterday",
                    color: .orange
                )
                
                RecentActivityRow(
                    icon: "figure.run",
                    title: "Morning Run",
                    time: "25 min",
                    calories: "280 cal",
                    date: "2 days ago",
                    color: .blue
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.appTheme.surface)
        }
    }
}

struct RecentActivityRow: View {
    let icon: String
    let title: String
    let time: String
    let calories: String
    let date: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color.appTheme.textPrimary)
                
                HStack(spacing: 12) {
                    Label(time, systemImage: "clock")
                    Label(calories, systemImage: "flame.fill")
                }
                .font(.caption)
                .foregroundColor(Color.appTheme.textSecondary)
            }
            
            Spacer()
            
            Text(date)
                .font(.caption)
                .foregroundColor(Color.appTheme.textTertiary)
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.appTheme.background)
        }
    }
}

// MARK: - Preview
#Preview {
    ActivityDashboardView()
        .preferredColorScheme(.dark)
}

