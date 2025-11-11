//
//  GoalAchievementView.swift
//  FootballApp
//
//  Final onboarding step with BMR calculation and summary
//

import SwiftUI

struct GoalAchievementView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    
    @State private var isSubmitting = false
    @State private var showSummary = false
    @State private var animateMetrics = false
    
    var body: some View {
        ZStack {
            if showSummary {
                OnboardingSummaryView(viewModel: viewModel, isSubmitting: $isSubmitting)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
                GoalVisualizationView(
                    viewModel: viewModel,
                    animateMetrics: $animateMetrics,
                    onContinue: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            showSummary = true
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75).delay(0.3)) {
                animateMetrics = true
            }
        }
    }
}

// MARK: - Goal Visualization View
struct GoalVisualizationView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var animateMetrics: Bool
    let onContinue: () -> Void
    
    var body: some View {
        ModernOnboardingQuestionView(
            title: "Votre Profil est Prêt !",
            subtitle: "Visualisez vos objectifs et métriques",
            buttonTitle: "Voir le Résumé",
            action: onContinue
        ) {
            VStack(spacing: 20) {
                // Goal card
                GoalCard(
                    goal: viewModel.data.goal ?? "MAINTENANCE",
                    animateMetrics: animateMetrics
                )
                
                // Metrics grid
                MetricsGrid(viewModel: viewModel, animateMetrics: animateMetrics)
            }
        }
    }
}

// MARK: - Goal Card
struct GoalCard: View {
    let goal: String
    let animateMetrics: Bool
    
    var goalInfo: (icon: String, title: String, color: Color) {
        switch goal {
        case "WEIGHT_LOSS":
            return ("flame.fill", "Perte de Poids", Color.red)
        case "MUSCLE_GAIN":
            return ("figure.strengthtraining.traditional", "Prise de Masse", Color.blue)
        case "MAINTENANCE":
            return ("heart.fill", "Maintien de Forme", Color.green)
        default:
            return ("star.fill", "Objectif Personnalisé", Color.purple)
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(goalInfo.color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: goalInfo.icon)
                    .font(.title2)
                    .foregroundColor(goalInfo.color)
            }
            .scaleEffect(animateMetrics ? 1 : 0.5)
            .opacity(animateMetrics ? 1 : 0)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Votre Objectif")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                
                Text(goalInfo.title)
                    .font(.title3.bold())
                    .foregroundColor(.white)
            }
            .opacity(animateMetrics ? 1 : 0)
            .offset(x: animateMetrics ? 0 : -20)
            
            Spacer()
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(goalInfo.color.opacity(0.4), lineWidth: 2)
                }
        }
    }
}

// MARK: - Metrics Grid
struct MetricsGrid: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let animateMetrics: Bool
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            MetricCard(
                icon: "ruler.fill",
                title: "Taille",
                value: "\(Int(viewModel.data.height ?? 170)) cm",
                color: .blue,
                animateMetrics: animateMetrics,
                delay: 0.1
            )
            
            MetricCard(
                icon: "scalemass.fill",
                title: "Poids",
                value: "\(Int(viewModel.data.weight ?? 70)) kg",
                color: .purple,
                animateMetrics: animateMetrics,
                delay: 0.2
            )
            
            MetricCard(
                icon: "target",
                title: "Objectif",
                value: "\(Int(viewModel.data.idealWeight ?? 70)) kg",
                color: .green,
                animateMetrics: animateMetrics,
                delay: 0.3
            )
            
            MetricCard(
                icon: "calendar",
                title: "Âge",
                value: "\(viewModel.data.age ?? 25) ans",
                color: .orange,
                animateMetrics: animateMetrics,
                delay: 0.4
            )
        }
    }
}

// MARK: - Metric Card
struct MetricCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let animateMetrics: Bool
    let delay: Double
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
            
            Text(value)
                .font(.headline.bold())
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                }
        }
        .scaleEffect(animateMetrics ? 1 : 0.8)
        .opacity(animateMetrics ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.75).delay(delay), value: animateMetrics)
    }
}

// MARK: - Onboarding Summary View
struct OnboardingSummaryView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var isSubmitting: Bool
    
    @State private var animateContent = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var bmr: Double {
        calculateBMR(
            gender: viewModel.data.gender ?? "HOMME",
            weight: viewModel.data.weight ?? 70,
            height: viewModel.data.height ?? 170,
            age: viewModel.data.age ?? 25
        )
    }
    
    var dailyCalories: Double {
        let activityMultiplier = getActivityMultiplier(viewModel.data.activityLevel ?? "MODERATE")
        return bmr * activityMultiplier
    }
    
    var adjustedCalories: Double {
        let goalAdjustment = getGoalAdjustment(viewModel.data.goal ?? "MAINTENANCE")
        return dailyCalories * goalAdjustment
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 100, height: 100)
                                .overlay {
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                colors: [.green, .blue],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 4
                                        )
                                }
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 50, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.green, .blue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        .scaleEffect(animateContent ? 1 : 0.5)
                        .opacity(animateContent ? 1 : 0)
                        
                        Text("Profil Complété !")
                            .font(.title.bold())
                            .foregroundColor(.white)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                        
                        Text("Voici votre plan nutritionnel personnalisé")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .opacity(animateContent ? 1 : 0)
                    }
                    .padding(.top, 40)
                    .padding(.horizontal, 24)
                    
                    // BMR & Calories Card
                    VStack(spacing: 16) {
                        CalorieMetricRow(
                            title: "Métabolisme de Base (MB)",
                            value: String(format: "%.0f kcal", bmr),
                            icon: "flame.fill",
                            color: .orange,
                            subtitle: "Calories brûlées au repos"
                        )
                        
                        Divider()
                            .background(.white.opacity(0.2))
                        
                        CalorieMetricRow(
                            title: "Dépense Énergétique Totale",
                            value: String(format: "%.0f kcal", dailyCalories),
                            icon: "bolt.fill",
                            color: .yellow,
                            subtitle: "Avec votre niveau d'activité"
                        )
                        
                        Divider()
                            .background(.white.opacity(0.2))
                        
                        CalorieMetricRow(
                            title: "Apport Calorique Recommandé",
                            value: String(format: "%.0f kcal", adjustedCalories),
                            icon: "target",
                            color: .green,
                            subtitle: "Pour atteindre votre objectif"
                        )
                    }
                    .padding(20)
                    .background {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay {
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                            }
                    }
                    .padding(.horizontal, 24)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 30)
                    
                    // Profile Summary
                    ProfileSummaryCard(viewModel: viewModel)
                        .padding(.horizontal, 24)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 40)
                    
                    // Information note
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Basé sur la formule de Harris-Benedict")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                            
                            Text("Votre plan sera ajusté selon vos progrès et vos habitudes alimentaires")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(16)
                    .background {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.blue.opacity(0.2))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(.blue.opacity(0.3), lineWidth: 1)
                            }
                    }
                    .padding(.horizontal, 24)
                    .opacity(animateContent ? 1 : 0)
                }
                .padding(.bottom, 120)
            }
            
            // Bottom action
            VStack(spacing: 16) {
                if showError {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 24)
                }
                
                Button(action: {
                    submitOnboarding()
                }) {
                    HStack(spacing: 12) {
                        if isSubmitting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Terminer")
                                .font(.headline.bold())
                            
                            Image(systemName: "checkmark")
                                .font(.headline)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [.green, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(.white.opacity(0.3), lineWidth: 1)
                            }
                    }
                    .shadow(color: .green.opacity(0.5), radius: 20, x: 0, y: 10)
                }
                .disabled(isSubmitting)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .background {
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color(hex: "1E1B4B").opacity(0.8),
                        Color(hex: "1E1B4B")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75).delay(0.2)) {
                animateContent = true
            }
        }
    }
    
    private func submitOnboarding() {
        isSubmitting = true
        showError = false
        
        Task {
            let success = await viewModel.submitOnboarding()
            
            await MainActor.run {
                isSubmitting = false
                
                if success {
                    // Move to main app
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) {
                        authViewModel.appState = .mainApp
                    }
                } else {
                    showError = true
                    errorMessage = viewModel.errorMessage ?? "Une erreur est survenue"
                }
            }
        }
    }
}

// MARK: - Calorie Metric Row
struct CalorieMetricRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Text(value)
                .font(.title3.bold())
                .foregroundColor(color)
        }
    }
}

// MARK: - Profile Summary Card
struct ProfileSummaryCard: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Résumé de votre profil")
                .font(.headline.bold())
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                if let discipline = viewModel.data.discipline {
                    SummaryRow(icon: "figure.run", title: "Discipline", value: discipline)
                }
                
                if let level = viewModel.data.level {
                    SummaryRow(icon: "chart.bar.fill", title: "Niveau", value: level)
                }
                
                if let morphology = viewModel.data.morphology {
                    SummaryRow(icon: "person.fill", title: "Morphologie", value: morphology)
                }
                
                if let isVegetarian = viewModel.data.isVegetarian {
                    SummaryRow(
                        icon: "leaf.fill",
                        title: "Régime",
                        value: isVegetarian ? "Végétarien" : "Standard"
                    )
                }
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                }
        }
    }
}

// MARK: - Summary Row
struct SummaryRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
        }
    }
}

// MARK: - BMR Calculation Functions
func calculateBMR(gender: String, weight: Double, height: Double, age: Int) -> Double {
    // Harris-Benedict Formula
    if gender == "HOMME" {
        // Men: BMR = 88.362 + (13.397 x weight) + (4.799 x height) - (5.677 x age)
        return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * Double(age))
    } else {
        // Women: BMR = 447.593 + (9.247 x weight) + (3.098 x height) - (4.330 x age)
        return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * Double(age))
    }
}

func getActivityMultiplier(_ activityLevel: String) -> Double {
    switch activityLevel {
    case "SEDENTARY":
        return 1.2
    case "LIGHT":
        return 1.375
    case "MODERATE":
        return 1.55
    case "VERY_ACTIVE":
        return 1.725
    case "EXTREMELY_ACTIVE":
        return 1.9
    default:
        return 1.55 // Default to moderate
    }
}

func getGoalAdjustment(_ goal: String) -> Double {
    switch goal {
    case "WEIGHT_LOSS":
        return 0.85 // -15% for weight loss
    case "MUSCLE_GAIN":
        return 1.15 // +15% for muscle gain
    case "MAINTENANCE":
        return 1.0 // Maintain current
    default:
        return 1.0
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        OnboardingBackground(currentStep: 35, totalSteps: 35)
            .ignoresSafeArea()
        
        GoalAchievementView(
            viewModel: OnboardingViewModel(),
            selection: .constant(35)
        )
        .environmentObject(AuthViewModel())
    }
}
