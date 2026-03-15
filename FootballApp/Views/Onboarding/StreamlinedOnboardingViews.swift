//
//  StreamlinedOnboardingViews.swift
//  FootballApp
//
//  Combined onboarding views for a streamlined 7-step flow.
//  Each view contains an internal sub-step TabView to pack
//  multiple related questions into one onboarding step.
//

import SwiftUI

// MARK: - Step 1: About You (Gender + Height + Weight)
struct AboutYouView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    @State private var subStep = 0

    var body: some View {
        TabView(selection: $subStep) {
            // Sub-step 0: Gender
            genderSection.tag(0)
            // Sub-step 1: Weight
            weightSection.tag(1)
            // Sub-step 2: Height
            heightSection.tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut(duration: 0.3), value: subStep)
    }

    private var genderSection: some View {
        ModernOnboardingQuestionView(
            title: "onboarding.gender.title",
            subtitle: "onboarding.gender.subtitle",
            buttonTitle: "common.next",
            action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    subStep = 1
                }
            }
        ) {
            HStack(spacing: 20) {
                GenderCard(
                    genderKey: "HOMME",
                    imageName: "male-icon",
                    isSelected: viewModel.data.gender == "HOMME"
                ) {
                    viewModel.data.gender = "HOMME"
                }
                GenderCard(
                    genderKey: "FEMME",
                    imageName: "female-icon",
                    isSelected: viewModel.data.gender == "FEMME"
                ) {
                    viewModel.data.gender = "FEMME"
                }
            }
        }
    }

    private var weightSection: some View {
        ModernOnboardingQuestionView(
            title: "onboarding.weight.title",
            subtitle: "onboarding.common.subtitle",
            buttonTitle: "common.next",
            action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    subStep = 2
                }
            }
        ) {
            VStack(spacing: 16) {
                Text(String(format: "%.1f kg", viewModel.data.weight ?? 70.0))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Slider(
                    value: Binding(
                        get: { viewModel.data.weight ?? 70.0 },
                        set: { viewModel.data.weight = $0 }
                    ),
                    in: 40...150,
                    step: 0.5
                )
                .tint(.white)
            }
            .padding(24)
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

    private var heightSection: some View {
        ModernOnboardingQuestionView(
            title: "onboarding.height.title",
            subtitle: "onboarding.common.subtitle",
            buttonTitle: "common.next",
            action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    selection += 1
                }
            }
        ) {
            VStack(spacing: 16) {
                Text(String(format: "%.0f cm", viewModel.data.height ?? 170.0))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Picker("Height", selection: Binding(
                    get: { viewModel.data.height ?? 170.0 },
                    set: { viewModel.data.height = $0 }
                )) {
                    ForEach(100...250, id: \.self) { h in
                        Text("\(h) cm").tag(Double(h))
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                .colorScheme(.dark)
            }
        }
    }
}

// MARK: - Step 2: Sport & Level (Discipline + Player Profile + Fitness Level)
struct SportAndLevelView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    @State private var subStep = 0

    private var showPlayerProfile: Bool {
        viewModel.data.discipline != nil && viewModel.data.discipline != "FITNESS"
    }

    private var totalSubSteps: Int {
        showPlayerProfile ? 3 : 2
    }

    var body: some View {
        TabView(selection: $subStep) {
            // Sub-step 0: Discipline
            disciplineSection.tag(0)

            if showPlayerProfile {
                // Sub-step 1: Player Profile (only for non-FITNESS)
                playerProfileSection.tag(1)
            }

            // Sub-step 1 or 2: Fitness Level
            fitnessLevelSection.tag(showPlayerProfile ? 2 : 1)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut(duration: 0.3), value: subStep)
    }

    private var disciplineSection: some View {
        ModernOnboardingQuestionView(
            title: "onboarding.discipline.title",
            subtitle: "onboarding.discipline.subtitle",
            buttonTitle: "common.next",
            action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    // Skip player profile if FITNESS
                    subStep = (viewModel.data.discipline == "FITNESS") ? 1 : 1
                }
            }
        ) {
            VStack(spacing: 12) {
                ForEach(viewModel.options?.discipline ?? []) { discipline in
                    OnboardingSelectionCardView(
                        icon: disciplineIcon(discipline.key),
                        title: discipline.name,
                        subtitle: nil,
                        isSelected: viewModel.data.discipline == discipline.key,
                        action: {
                            viewModel.data.discipline = discipline.key
                        }
                    )
                }
            }
        }
    }

    private var playerProfileSection: some View {
        ModernOnboardingQuestionView(
            title: "onboarding.player_profile.title",
            subtitle: "onboarding.player_profile.subtitle",
            buttonTitle: "common.next",
            action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    subStep = 2
                }
            }
        ) {
            ScrollView {
                VStack(spacing: 20) {
                    let profileGroups = viewModel.options?.player_profiles?.keys.sorted() ?? []
                    ForEach(profileGroups, id: \.self) { groupName in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(groupName)
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal, 4)

                            ForEach(viewModel.options?.player_profiles?[groupName] ?? []) { profile in
                                OnboardingSelectionCardView(
                                    icon: "figure.soccer",
                                    title: profile.name,
                                    subtitle: nil,
                                    isSelected: viewModel.data.position == profile.key,
                                    action: {
                                        viewModel.data.position = profile.key
                                    }
                                )
                            }
                        }
                    }
                }
            }
            .frame(maxHeight: 400)
        }
    }

    private var fitnessLevelSection: some View {
        ModernOnboardingQuestionView(
            title: "onboarding.fitness_level.title",
            subtitle: "onboarding.fitness_level.subtitle",
            buttonTitle: "common.next",
            action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    selection += 1
                }
            }
        ) {
            VStack(spacing: 12) {
                ForEach(viewModel.options?.level ?? []) { level in
                    OnboardingSelectionCardView(
                        icon: "chart.bar.fill",
                        title: level.name,
                        subtitle: nil,
                        isSelected: viewModel.data.level == level.key,
                        action: {
                            viewModel.data.level = level.key
                        }
                    )
                }
            }
        }
    }

    private func disciplineIcon(_ key: String) -> String {
        switch key {
        case "FOOTBALL": return "figure.soccer"
        case "FITNESS": return "figure.strengthtraining.traditional"
        case "BASKETBALL": return "figure.basketball"
        case "TENNIS": return "figure.tennis"
        default: return "figure.run"
        }
    }
}

// MARK: - Step 3: Goals & Training (Goal + Ideal Weight + Location + Days)
struct GoalsAndTrainingView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    @State private var subStep = 0
    @State private var selectedDays: Set<String> = []

    let locationOptions = [
        ("HOME", "onboarding.training_location.home_label", "house.fill"),
        ("GYM", "onboarding.training_location.gym_label", "dumbbell.fill"),
        ("OUTDOOR", "onboarding.training_location.outdoor_label", "leaf.fill"),
        ("MIXED", "onboarding.training_location.mixed", "arrow.triangle.2.circlepath")
    ]

    let dayOptions = ["LUN", "MAR", "MER", "JEU", "VEN", "SAM", "DIM"]

    var body: some View {
        TabView(selection: $subStep) {
            // Sub-step 0: Goal selection
            goalSection.tag(0)
            // Sub-step 1: Ideal weight
            idealWeightSection.tag(1)
            // Sub-step 2: Training location + days
            trainingSection.tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut(duration: 0.3), value: subStep)
        .onAppear {
            if let days = viewModel.data.trainingDays {
                selectedDays = Set(days)
            }
        }
    }

    private var goalSection: some View {
        ModernOnboardingQuestionView(
            title: "onboarding.goal.title",
            subtitle: "onboarding.goal.subtitle",
            buttonTitle: "common.next",
            action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    subStep = 1
                }
            }
        ) {
            VStack(spacing: 12) {
                ForEach(viewModel.options?.goal ?? []) { goal in
                    OnboardingSelectionCardView(
                        icon: goalIcon(goal.key),
                        title: goal.name,
                        subtitle: nil,
                        isSelected: viewModel.data.goal == goal.key,
                        action: {
                            viewModel.data.goal = goal.key
                        }
                    )
                }
            }
        }
    }

    private var idealWeightSection: some View {
        ModernOnboardingQuestionView(
            title: "onboarding.ideal_weight.title",
            subtitle: "onboarding.ideal_weight.subtitle",
            buttonTitle: "common.next",
            action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    subStep = 2
                }
            }
        ) {
            VStack(spacing: 16) {
                Text(String(format: "%.1f kg", viewModel.data.idealWeight ?? 70.0))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Slider(
                    value: Binding(
                        get: { viewModel.data.idealWeight ?? 70.0 },
                        set: { viewModel.data.idealWeight = $0 }
                    ),
                    in: 40...150,
                    step: 0.5
                )
                .tint(.white)
            }
            .padding(24)
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

    private var trainingSection: some View {
        ModernOnboardingQuestionView(
            title: "onboarding.training_setup.title",
            subtitle: "onboarding.training_setup.subtitle",
            buttonTitle: "common.continue",
            action: {
                viewModel.data.trainingDays = Array(selectedDays)
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    selection += 1
                }
            }
        ) {
            VStack(spacing: 24) {
                // Location selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("onboarding.training_location.title".localizedString)
                        .font(.headline)
                        .foregroundColor(.white)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(locationOptions, id: \.0) { option in
                            Button {
                                viewModel.data.trainingLocation = option.0
                            } label: {
                                VStack(spacing: 8) {
                                    Image(systemName: option.2)
                                        .font(.title2)
                                    Text(option.1.localizedString)
                                        .font(.caption)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(viewModel.data.trainingLocation == option.0 ? Color.white.opacity(0.25) : Color.white.opacity(0.1))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(viewModel.data.trainingLocation == option.0 ? Color.white : Color.clear, lineWidth: 2)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // Days selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("nutrition.onboarding.training_days".localizedString)
                        .font(.headline)
                        .foregroundColor(.white)

                    HStack(spacing: 8) {
                        ForEach(dayOptions, id: \.self) { day in
                            Button {
                                if selectedDays.contains(day) {
                                    selectedDays.remove(day)
                                } else {
                                    selectedDays.insert(day)
                                }
                            } label: {
                                Text(localizedDayName(day))
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        Circle()
                                            .fill(selectedDays.contains(day) ? Color.white.opacity(0.3) : Color.white.opacity(0.1))
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(selectedDays.contains(day) ? Color.white : Color.clear, lineWidth: 2)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private func goalIcon(_ key: String) -> String {
        switch key {
        case "WEIGHT_LOSS": return "flame.fill"
        case "MUSCLE_GAIN": return "figure.strengthtraining.traditional"
        case "MAINTENANCE": return "heart.fill"
        default: return "flag.checkered"
        }
    }

    private func localizedDayName(_ apiKey: String) -> String {
        switch apiKey {
        case "LUN": return "day.mon".localizedString
        case "MAR": return "day.tue".localizedString
        case "MER": return "day.wed".localizedString
        case "JEU": return "day.thu".localizedString
        case "VEN": return "day.fri".localizedString
        case "SAM": return "day.sat".localizedString
        case "DIM": return "day.sun".localizedString
        default: return apiKey
        }
    }
}

// MARK: - Step 4: Nutrition Habits (Diet + Habits + Food Grid)
struct NutritionHabitsView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    @State private var subStep = 0
    @State private var selectedMeals: Set<String> = []
    @State private var selectedHabits: Set<String> = []

    let mealOptions = [
        ("MORNING", "onboarding.diet.breakfast", "sunrise.fill"),
        ("NOON", "onboarding.diet.lunch", "sun.max.fill"),
        ("EVENING", "onboarding.diet.dinner", "moon.stars.fill")
    ]

    let habitOptions = [
        ("LATE_EATING", "onboarding.habits.late_eating", "moon.zzz.fill"),
        ("INSUFFICIENT_SLEEP", "onboarding.habits.insufficient_sleep", "bed.double.fill"),
        ("SWEETS_LOVER", "onboarding.habits.sweets_lover", "birthday.cake.fill"),
        ("TOO_MUCH_SALT", "onboarding.habits.too_much_salt", "shippingbox.fill"),
        ("DRINK_SODAS", "onboarding.habits.drink_sodas", "cup.and.saucer.fill"),
        ("SNACKING", "onboarding.habits.snacking", "popcorn.fill")
    ]

    let foodCategories: [(key: String, emoji: String, nameKey: String, binding: WritableKeyPath<OnboardingData, String?>)] = [
        ("vegetables", "🥦", "onboarding.food.vegetables", \.vegetableConsumption),
        ("fruits", "🍎", "onboarding.food.fruits", \.fruitConsumption),
        ("meat", "🥩", "onboarding.food.meat", \.meatConsumption),
        ("fish", "🐟", "onboarding.food.fish", \.fishConsumption),
        ("dairy", "🥛", "onboarding.food.dairy", \.dairyConsumption),
        ("eggs", "🥚", "onboarding.food.eggs", \.eggConsumption),
        ("cereals", "🌾", "onboarding.food.cereals", \.cerealConsumption),
        ("starchy", "🍝", "onboarding.food.starchy", \.starchyFoodConsumption),
        ("sugary", "🍭", "onboarding.food.sugary", \.sugaryFoodConsumption)
    ]

    let frequencyOptions: [(String, String, Color)] = [
        ("EVERYDAY", "onboarding.food.daily", .green),
        ("1-2_WEEK", "onboarding.food.weekly", .orange),
        ("NEVER", "onboarding.food.never", .red.opacity(0.7))
    ]

    var body: some View {
        TabView(selection: $subStep) {
            // Sub-step 0: Diet preferences (vegetarian + meals)
            dietSection.tag(0)
            // Sub-step 1: Eating habits + food grid combined
            habitsAndFoodSection.tag(1)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut(duration: 0.3), value: subStep)
        .onAppear {
            if let meals = viewModel.data.mealsPerDay?.components(separatedBy: ",") {
                selectedMeals = Set(meals)
            }
            if let habits = viewModel.data.badHabits {
                selectedHabits = Set(habits)
            }
        }
    }

    private var dietSection: some View {
        ModernOnboardingQuestionView(
            title: "onboarding.diet.title",
            subtitle: "onboarding.diet.subtitle",
            buttonTitle: "common.next",
            action: {
                viewModel.data.mealsPerDay = Array(selectedMeals).joined(separator: ",")
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    subStep = 1
                }
            }
        ) {
            VStack(spacing: 24) {
                // Vegetarian toggle
                VStack(alignment: .leading, spacing: 12) {
                    Text("nutrition.onboarding.diet_type".localizedString)
                        .font(.headline)
                        .foregroundColor(.white)

                    HStack(spacing: 12) {
                        Button {
                            viewModel.data.isVegetarian = false
                        } label: {
                            HStack {
                                Image(systemName: "fork.knife")
                                Text("nutrition.onboarding.omnivore".localizedString)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(viewModel.data.isVegetarian == false ? Color.white.opacity(0.25) : Color.white.opacity(0.1))
                            )
                        }
                        .buttonStyle(.plain)

                        Button {
                            viewModel.data.isVegetarian = true
                        } label: {
                            HStack {
                                Image(systemName: "leaf.fill")
                                Text("nutrition.onboarding.vegetarian".localizedString)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(viewModel.data.isVegetarian == true ? Color.white.opacity(0.25) : Color.white.opacity(0.1))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                // Meals per day
                VStack(alignment: .leading, spacing: 12) {
                    Text("nutrition.onboarding.daily_meals".localizedString)
                        .font(.headline)
                        .foregroundColor(.white)

                    ForEach(mealOptions, id: \.0) { meal in
                        Button {
                            if selectedMeals.contains(meal.0) {
                                selectedMeals.remove(meal.0)
                            } else {
                                selectedMeals.insert(meal.0)
                            }
                        } label: {
                            HStack {
                                Image(systemName: meal.2)
                                    .font(.title3)
                                Text(meal.1.localizedString)
                                Spacer()
                                Image(systemName: selectedMeals.contains(meal.0) ? "checkmark.circle.fill" : "circle")
                            }
                            .foregroundColor(.white)
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedMeals.contains(meal.0) ? Color.white.opacity(0.2) : Color.white.opacity(0.1))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var habitsAndFoodSection: some View {
        ModernOnboardingQuestionView(
            title: "onboarding.habits.title",
            subtitle: "onboarding.habits.subtitle",
            buttonTitle: "common.continue",
            action: {
                viewModel.data.badHabits = Array(selectedHabits)
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    selection += 1
                }
            }
        ) {
            ScrollView {
                VStack(spacing: 24) {
                    // Bad habits checklist
                    VStack(spacing: 10) {
                        ForEach(habitOptions, id: \.0) { habit in
                            Button {
                                if selectedHabits.contains(habit.0) {
                                    selectedHabits.remove(habit.0)
                                } else {
                                    selectedHabits.insert(habit.0)
                                }
                            } label: {
                                HStack {
                                    Image(systemName: habit.2)
                                        .font(.body)
                                        .frame(width: 24)
                                    Text(habit.1.localizedString)
                                        .font(.subheadline)
                                    Spacer()
                                    Image(systemName: selectedHabits.contains(habit.0) ? "checkmark.circle.fill" : "circle")
                                }
                                .foregroundColor(.white)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedHabits.contains(habit.0) ? Color.white.opacity(0.2) : Color.white.opacity(0.1))
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Divider
                    HStack {
                        VStack { Divider().background(.white.opacity(0.3)) }
                        Text("onboarding.food.title".localizedString)
                            .font(.caption.bold())
                            .foregroundColor(.white.opacity(0.7))
                        VStack { Divider().background(.white.opacity(0.3)) }
                    }
                    .padding(.vertical, 4)

                    // Food consumption grid
                    VStack(spacing: 10) {
                        ForEach(foodCategories, id: \.key) { category in
                            HStack(spacing: 10) {
                                HStack(spacing: 6) {
                                    Text(category.emoji)
                                        .font(.body)
                                    Text(category.nameKey.localizedString)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                                .frame(width: 95, alignment: .leading)

                                HStack(spacing: 4) {
                                    ForEach(frequencyOptions, id: \.0) { option in
                                        Button {
                                            viewModel.data[keyPath: category.binding] = option.0
                                        } label: {
                                            Text(option.1.localizedString)
                                                .font(.system(size: 10))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 5)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 6)
                                                        .fill(viewModel.data[keyPath: category.binding] == option.0 ? option.2 : Color.white.opacity(0.1))
                                                )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.05))
                            )
                        }
                    }
                }
            }
            .frame(maxHeight: 500)
        }
    }
}

// MARK: - Step 5: Health Overview (Health Info + Medical History)
struct HealthOverviewView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    @State private var selectedConditions: Set<String> = []

    let conditions = [
        ("ALLERGIES", "onboarding.medical.allergies", "allergens"),
        ("LACTOSE_INTOLERANCE", "onboarding.medical.lactose", "drop.fill"),
        ("ASTHMA", "onboarding.medical.asthma", "lungs.fill"),
        ("DIGESTIVE_TROUBLES", "onboarding.medical.digestive", "stomach"),
        ("FATIGUE", "onboarding.medical.fatigue", "bed.double.fill"),
        ("SKIN_TROUBLES", "onboarding.medical.skin", "hand.raised.fill"),
        ("JOINT_PAIN", "onboarding.medical.joints", "figure.flexibility"),
        ("MIGRAINES", "onboarding.medical.migraines", "bolt.heart.fill"),
        ("HYPERTENSION", "onboarding.medical.hypertension", "heart.fill"),
        ("CHOLESTEROL", "onboarding.medical.cholesterol", "waveform.path.ecg"),
        ("SLEEP_DISORDERS", "onboarding.medical.sleep", "moon.zzz.fill")
    ]

    var body: some View {
        ModernOnboardingQuestionView(
            title: "onboarding.health.title",
            subtitle: "onboarding.health.subtitle",
            buttonTitle: "onboarding.medical.finish",
            action: {
                viewModel.data.medicalHistory = Array(selectedConditions)
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    selection += 1
                }
            }
        ) {
            ScrollView {
                VStack(spacing: 20) {
                    // Health toggles (medication, diabetes, hormonal)
                    VStack(spacing: 12) {
                        HealthToggleRow(
                            icon: "💊",
                            title: "onboarding.health.medication".localizedString,
                            isSelected: Binding(
                                get: { viewModel.data.takesMedication ?? false },
                                set: { viewModel.data.takesMedication = $0 }
                            )
                        )

                        HealthToggleRow(
                            icon: "🩸",
                            title: "onboarding.health.diabetes".localizedString,
                            isSelected: Binding(
                                get: { viewModel.data.hasDiabetes ?? false },
                                set: { viewModel.data.hasDiabetes = $0 }
                            )
                        )

                        HealthToggleRow(
                            icon: "⚡️",
                            title: "onboarding.health.hormonal".localizedString,
                            isSelected: Binding(
                                get: { viewModel.data.hasHormonalIssues ?? false },
                                set: { viewModel.data.hasHormonalIssues = $0 }
                            )
                        )
                    }

                    // Divider
                    HStack {
                        VStack { Divider().background(.white.opacity(0.3)) }
                        Text("onboarding.medical.title".localizedString)
                            .font(.caption.bold())
                            .foregroundColor(.white.opacity(0.7))
                        VStack { Divider().background(.white.opacity(0.3)) }
                    }
                    .padding(.vertical, 4)

                    // Medical conditions grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(conditions, id: \.0) { condition in
                            Button {
                                if selectedConditions.contains(condition.0) {
                                    selectedConditions.remove(condition.0)
                                } else {
                                    selectedConditions.insert(condition.0)
                                }
                            } label: {
                                HStack(spacing: 5) {
                                    Image(systemName: condition.2)
                                        .font(.caption)
                                    Text(condition.1.localizedString)
                                        .font(.caption2)
                                        .lineLimit(1)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(selectedConditions.contains(condition.0) ? Color.white.opacity(0.25) : Color.white.opacity(0.1))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(selectedConditions.contains(condition.0) ? Color.white.opacity(0.5) : Color.clear, lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .frame(maxHeight: 500)
        }
        .onAppear {
            if let history = viewModel.data.medicalHistory {
                selectedConditions = Set(history)
            }
        }
    }
}

// MARK: - Preview
#Preview("Streamlined Onboarding") {
    ZStack {
        OnboardingBackground(currentStep: 1, totalSteps: 7)
            .ignoresSafeArea()

        AboutYouView(
            viewModel: OnboardingViewModel(),
            selection: .constant(1)
        )
    }
}
