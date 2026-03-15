//
//  NutritionOnboardingViews.swift
//  FootballApp
//
//  Comprehensive nutrition onboarding steps based on Prophetic Medicine
//

import SwiftUI

// MARK: - Meals Per Day View
struct MealsPerDayView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    @State private var selectedMeals: Set<String> = []
    
    let mealOptions = [
        ("MORNING", "Petit-déjeuner", "sunrise.fill"),
        ("NOON", "Déjeuner", "sun.max.fill"),
        ("EVENING", "Dîner", "moon.stars.fill")
    ]
    
    var body: some View {
        ModernOnboardingQuestionView(
            title: "Combien de repas par jour ?",
            subtitle: "Sélectionnez vos repas habituels",
            buttonTitle: "Continuer",
            action: {
                viewModel.data.mealsPerDay = Array(selectedMeals).joined(separator: ",")
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    selection += 1
                }
            }
        ) {
            VStack(spacing: 16) {
                ForEach(mealOptions, id: \.0) { meal in
                    OnboardingSelectionCardView(
                        icon: meal.2,
                        title: meal.1,
                        subtitle: nil,
                        isSelected: selectedMeals.contains(meal.0),
                        action: {
                            if selectedMeals.contains(meal.0) {
                                selectedMeals.remove(meal.0)
                            } else {
                                selectedMeals.insert(meal.0)
                            }
                        }
                    )
                }
                
                if selectedMeals.isEmpty {
                    Text("nutrition.onboarding.select_meal".localizedString)
                        .font(.caption)
                        .foregroundColor(.red.opacity(0.8))
                        .padding(.top, 8)
                }
            }
        }
        .onAppear {
            if let meals = viewModel.data.mealsPerDay?.components(separatedBy: ",") {
                selectedMeals = Set(meals)
            }
        }
    }
}

// MARK: - Breakfast Preferences View
struct BreakfastPreferencesView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    @State private var selectedPreferences: Set<String> = []
    
    let breakfastOptions = [
        ("BREAD", "Pain", "🍞"),
        ("JAM", "Confiture", "🍯"),
        ("BUTTER", "Beurre", "🧈"),
        ("MILK", "Lait", "🥛"),
        ("COFFEE", "Café", "☕️"),
        ("HOT_CHOCOLATE", "Chocolat Chaud", "🍫"),
        ("TEA", "Thé", "🍵"),
        ("LEMON_JUICE", "Jus de Citron", "🍋"),
        ("FRUITS", "Fruits", "🍎"),
        ("FRUIT_JUICE", "Jus de Fruits", "🧃"),
        ("EGGS", "Œufs", "🥚"),
        ("SKIP", "Je saute ce repas", "⏭️")
    ]
    
    var body: some View {
        ModernOnboardingQuestionView(
            title: "Au petit-déjeuner qu'aimez-vous ?",
            subtitle: "Sélectionnez vos préférences",
            buttonTitle: "Continuer",
            action: {
                viewModel.data.breakfastPreferences = Array(selectedPreferences)
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    selection += 1
                }
            }
        ) {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(breakfastOptions, id: \.0) { option in
                        HStack {
                            Text(option.2)
                                .font(.title2)
                            
                            Text(option.1)
                                .font(.body)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .stroke(.white.opacity(0.3), lineWidth: 2)
                                    .frame(width: 24, height: 24)
                                
                                if selectedPreferences.contains(option.0) {
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 16, height: 16)
                                }
                            }
                        }
                        .padding(16)
                        .background {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(selectedPreferences.contains(option.0) ? .white.opacity(0.2) : .white.opacity(0.1))
                        }
                        .onTapGesture {
                            if selectedPreferences.contains(option.0) {
                                selectedPreferences.remove(option.0)
                            } else {
                                selectedPreferences.insert(option.0)
                            }
                        }
                    }
                }
            }
            .frame(maxHeight: 400)
        }
        .onAppear {
            if let prefs = viewModel.data.breakfastPreferences {
                selectedPreferences = Set(prefs)
            }
        }
    }
}

// MARK: - Bad Habits View
struct BadHabitsView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    @State private var selectedHabits: Set<String> = []
    
    let habitOptions = [
        ("LATE_EATING", "Je mange tard le soir", "moon.zzz.fill"),
        ("INSUFFICIENT_SLEEP", "Je ne dors pas assez", "bed.double.fill"),
        ("SWEETS_LOVER", "J'aime trop les sucreries", "birthday.cake.fill"),
        ("TOO_MUCH_SALT", "Je consomme beaucoup de sel", "shippingbox.fill"),
        ("DRINK_SODAS", "Je bois des sodas", "cup.and.saucer.fill")
    ]
    
    var body: some View {
        ModernOnboardingQuestionView(
            title: "Vos mauvaises habitudes ?",
            subtitle: "Sélectionnez celles qui s'appliquent à vous",
            buttonTitle: "Continuer",
            action: {
                viewModel.data.badHabits = Array(selectedHabits)
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    selection += 1
                }
            }
        ) {
            VStack(spacing: 16) {
                ForEach(habitOptions, id: \.0) { habit in
                    OnboardingSelectionCardView(
                        icon: habit.2,
                        title: habit.1,
                        subtitle: nil,
                        isSelected: selectedHabits.contains(habit.0),
                        action: {
                            if selectedHabits.contains(habit.0) {
                                selectedHabits.remove(habit.0)
                            } else {
                                selectedHabits.insert(habit.0)
                            }
                        }
                    )
                }
            }
        }
        .onAppear {
            if let habits = viewModel.data.badHabits {
                selectedHabits = Set(habits)
            }
        }
    }
}

// MARK: - Snacking Habits View
struct SnackingHabitsView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    
    let snackingOptions = [
        ("EVERYDAY", "Tous les jours", "calendar"),
        ("STRESS", "En période de stress", "brain.head.profile"),
        ("WORK", "Au travail", "briefcase.fill"),
        ("BOREDOM", "En période d'ennui", "figure.mind.and.body"),
        ("RARELY", "Rarement", "clock.badge.checkmark"),
        ("NEVER", "Jamais", "xmark.circle.fill")
    ]
    
    var body: some View {
        ModernOnboardingQuestionView(
            title: "Vous grignotez tout au long de la journée ?",
            subtitle: "Sélectionnez votre fréquence",
            buttonTitle: "Continuer",
            action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    selection += 1
                }
            }
        ) {
            VStack(spacing: 16) {
                ForEach(snackingOptions, id: \.0) { option in
                    OnboardingSelectionCardView(
                        icon: option.2,
                        title: option.1,
                        subtitle: nil,
                        isSelected: viewModel.data.snackingHabits == option.0,
                        action: {
                            viewModel.data.snackingHabits = option.0
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Food Consumption Template View
struct FoodConsumptionView: View {
    let title: String
    let icon: String
    let emoji: String
    @Binding var selection: String?
    let onContinue: () -> Void
    
    let consumptionOptions = [
        ("EVERYDAY", "Tous les jours"),
        ("1-2_WEEK", "1-2 fois par semaine"),
        ("NEVER", "Jamais"),
        ("DISLIKE", "Je n'aime pas")
    ]
    
    var body: some View {
        ModernOnboardingQuestionView(
            title: LocalizedStringKey(title),
            subtitle: "Sélectionnez votre fréquence de consommation",
            buttonTitle: "Continuer",
            action: onContinue
        ) {
            VStack(spacing: 16) {
                // Large emoji display
                Text(emoji)
                    .font(.system(size: 80))
                    .padding(.vertical, 20)
                
                ForEach(consumptionOptions, id: \.0) { option in
                    OnboardingSelectionCardView(
                        icon: icon,
                        title: option.1,
                        subtitle: nil,
                        isSelected: selection == option.0,
                        action: {
                            selection = option.0
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Vegetable Consumption View
struct VegetableConsumptionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    
    var body: some View {
        FoodConsumptionView(
            title: "Consommez-vous régulièrement des légumes ?",
            icon: "leaf.fill",
            emoji: "🥦",
            selection: $viewModel.data.vegetableConsumption,
            onContinue: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    selection += 1
                }
            }
        )
    }
}

// MARK: - Fish Consumption View
struct FishConsumptionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    
    var body: some View {
        FoodConsumptionView(
            title: "Consommez-vous régulièrement du poisson ?",
            icon: "fish.fill",
            emoji: "🐟",
            selection: $viewModel.data.fishConsumption,
            onContinue: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    selection += 1
                }
            }
        )
    }
}

// MARK: - Meat Consumption View
struct MeatConsumptionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    
    var body: some View {
        FoodConsumptionView(
            title: "Consommez-vous régulièrement de la viande ?",
            icon: "flame.fill",
            emoji: "🥩",
            selection: $viewModel.data.meatConsumption,
            onContinue: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    selection += 1
                }
            }
        )
    }
}

// MARK: - Dairy Consumption View
struct DairyConsumptionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    
    var body: some View {
        FoodConsumptionView(
            title: "Consommez-vous régulièrement des produits laitiers ?",
            icon: "drop.fill",
            emoji: "🥛",
            selection: $viewModel.data.dairyConsumption,
            onContinue: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    selection += 1
                }
            }
        )
    }
}

// MARK: - Sugary Food Consumption View
struct SugaryFoodConsumptionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    
    var body: some View {
        FoodConsumptionView(
            title: "Consommez-vous régulièrement des aliments sucrés ?",
            icon: "star.fill",
            emoji: "🍭",
            selection: $viewModel.data.sugaryFoodConsumption,
            onContinue: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    selection += 1
                }
            }
        )
    }
}

// MARK: - Cereal Consumption View
struct CerealConsumptionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    
    var body: some View {
        FoodConsumptionView(
            title: "Consommez-vous régulièrement des céréales ?",
            icon: "square.grid.2x2.fill",
            emoji: "🌾",
            selection: $viewModel.data.cerealConsumption,
            onContinue: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    selection += 1
                }
            }
        )
    }
}

// MARK: - Starchy Food Consumption View
struct StarchyFoodConsumptionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    
    var body: some View {
        FoodConsumptionView(
            title: "Consommez-vous régulièrement des féculents ?",
            icon: "circle.grid.3x3.fill",
            emoji: "🍝",
            selection: $viewModel.data.starchyFoodConsumption,
            onContinue: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    selection += 1
                }
            }
        )
    }
}

// MARK: - Sugary Drink Consumption View
struct SugaryDrinkConsumptionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    
    let consumptionOptions = [
        ("EVERYDAY", "Tous les jours"),
        ("1-2_WEEK", "1-2 fois par semaine"),
        ("NEVER", "Jamais")
    ]
    
    var body: some View {
        ModernOnboardingQuestionView(
            title: "Consommez-vous régulièrement des boissons sucrées ?",
            subtitle: "Sélectionnez votre fréquence",
            buttonTitle: "Continuer",
            action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    selection += 1
                }
            }
        ) {
            VStack(spacing: 16) {
                Text("🥤")
                    .font(.system(size: 80))
                    .padding(.vertical, 20)
                
                ForEach(consumptionOptions, id: \.0) { option in
                    OnboardingSelectionCardView(
                        icon: "cup.and.saucer.fill",
                        title: option.1,
                        subtitle: nil,
                        isSelected: viewModel.data.sugaryDrinkConsumption == option.0,
                        action: {
                            viewModel.data.sugaryDrinkConsumption = option.0
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Egg Consumption View
struct EggConsumptionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    
    var body: some View {
        FoodConsumptionView(
            title: "Consommez-vous régulièrement des œufs ?",
            icon: "circle.fill",
            emoji: "🥚",
            selection: $viewModel.data.eggConsumption,
            onContinue: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    selection += 1
                }
            }
        )
    }
}

// MARK: - Fruit Consumption View
struct FruitConsumptionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    
    var body: some View {
        FoodConsumptionView(
            title: "Consommez-vous régulièrement des fruits ?",
            icon: "sparkles",
            emoji: "🍎",
            selection: $viewModel.data.fruitConsumption,
            onContinue: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    selection += 1
                }
            }
        )
    }
}

// MARK: - Medication View
struct MedicationView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    
    var body: some View {
        ModernOnboardingQuestionView(
            title: "Prenez-vous régulièrement des médicaments ?",
            subtitle: "Cette information nous aide à personnaliser vos recommandations",
            buttonTitle: "Continuer",
            action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    selection += 1
                }
            }
        ) {
            VStack(spacing: 16) {
                Text("💊")
                    .font(.system(size: 80))
                    .padding(.vertical, 20)
                
                OnboardingSelectionCardView(
                    icon: "checkmark.circle.fill",
                    title: "Oui",
                    subtitle: "Je prends des médicaments régulièrement",
                    isSelected: viewModel.data.takesMedication == true,
                    action: {
                        viewModel.data.takesMedication = true
                    }
                )
                
                OnboardingSelectionCardView(
                    icon: "xmark.circle.fill",
                    title: "Non",
                    subtitle: "Je ne prends pas de médicaments",
                    isSelected: viewModel.data.takesMedication == false,
                    action: {
                        viewModel.data.takesMedication = false
                    }
                )
            }
        }
    }
}

// MARK: - Diabetes View
struct DiabetesView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    
    var body: some View {
        ModernOnboardingQuestionView(
            title: "Avez-vous du diabète ?",
            subtitle: "Cette information est essentielle pour votre plan nutritionnel",
            buttonTitle: "Continuer",
            action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    selection += 1
                }
            }
        ) {
            VStack(spacing: 16) {
                Text("🩸")
                    .font(.system(size: 80))
                    .padding(.vertical, 20)
                
                OnboardingSelectionCardView(
                    icon: "checkmark.circle.fill",
                    title: "Oui",
                    subtitle: "J'ai du diabète",
                    isSelected: viewModel.data.hasDiabetes == true,
                    action: {
                        viewModel.data.hasDiabetes = true
                    }
                )
                
                OnboardingSelectionCardView(
                    icon: "xmark.circle.fill",
                    title: "Non",
                    subtitle: "Je n'ai pas de diabète",
                    isSelected: viewModel.data.hasDiabetes == false,
                    action: {
                        viewModel.data.hasDiabetes = false
                    }
                )
            }
        }
    }
}

// MARK: - Family History View
struct FamilyHistoryView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    @State private var selectedConditions: Set<String> = []
    
    let familyConditions = [
        ("OBESITY", "Surpoids/Obésité", "figure.walk"),
        ("DIABETES", "Diabète", "cross.case.fill"),
        ("CROHNS", "Maladie de Crohn", "heart.text.square.fill"),
        ("CELIAC", "Maladie Cœliaque", "leaf.fill"),
        ("RHEUMATISM", "Rhumatisme Inflammatoire", "figure.flexibility"),
        ("PSORIASIS", "Psoriasis", "hand.raised.fill"),
        ("KIDNEY", "Troubles Rénaux", "drop.triangle.fill"),
        ("ALLERGIES", "Allergies", "allergens"),
        ("INTOLERANCES", "Intolérances", "exclamationmark.triangle.fill")
    ]
    
    var body: some View {
        ModernOnboardingQuestionView(
            title: "Antécédents familiaux ?",
            subtitle: "Cochez les pathologies présentes dans votre famille",
            buttonTitle: "Continuer",
            action: {
                viewModel.data.familyHistory = Array(selectedConditions)
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    selection += 1
                }
            }
        ) {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(familyConditions, id: \.0) { condition in
                        HStack {
                            Image(systemName: condition.2)
                                .font(.title3)
                                .foregroundColor(.white)
                                .frame(width: 30)
                            
                            Text(condition.1)
                                .font(.body)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .stroke(.white.opacity(0.3), lineWidth: 2)
                                    .frame(width: 24, height: 24)
                                
                                if selectedConditions.contains(condition.0) {
                                    Image(systemName: "checkmark")
                                        .font(.caption.bold())
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(16)
                        .background {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(selectedConditions.contains(condition.0) ? .white.opacity(0.2) : .white.opacity(0.1))
                        }
                        .onTapGesture {
                            if selectedConditions.contains(condition.0) {
                                selectedConditions.remove(condition.0)
                            } else {
                                selectedConditions.insert(condition.0)
                            }
                        }
                    }
                }
            }
            .frame(maxHeight: 450)
        }
        .onAppear {
            if let history = viewModel.data.familyHistory {
                selectedConditions = Set(history)
            }
        }
    }
}

// MARK: - Medical History View
struct MedicalHistoryView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    @State private var selectedConditions: Set<String> = []
    
    let medicalConditions = [
        ("ALLERGIES", "Allergies", "allergens"),
        ("LACTOSE_INTOLERANCE", "Intolérance au Lactose", "drop.fill"),
        ("ECZEMA", "Eczéma", "hand.raised.fill"),
        ("URTICARIA", "Urticaire", "cross.case.fill"),
        ("ASTHMA", "Asthme", "lungs.fill"),
        ("DIGESTIVE_INFECTIONS", "Infections Digestives", "stomach"),
        ("DIGESTION_TROUBLES", "Troubles de la Digestion", "figure.walk"),
        ("FATIGUE", "Fatigue", "bed.double.fill"),
        ("MOOD_DISORDERS", "Troubles de l'Humeur", "brain.head.profile"),
        ("REPEATED_INFECTIONS", "Infections à Répétition", "bandage.fill"),
        ("SKIN_TROUBLES", "Troubles Cutanés", "hand.raised.fingers.spread.fill"),
        ("JOINT_PAIN", "Douleurs Articulaires", "figure.flexibility"),
        ("MIGRAINES", "Migraines", "bolt.heart.fill"),
        ("FOOD_INTOLERANCE", "Intolérance Alimentaire", "exclamationmark.triangle.fill"),
        ("DIABETES", "Diabète", "cross.case.fill"),
        ("HYPERTENSION", "Hypertension Artérielle", "heart.fill"),
        ("CHOLESTEROL", "Hypercholestérolémie", "waveform.path.ecg"),
        ("TRIGLYCERIDES", "Hypertriglycéridémie", "chart.line.uptrend.xyaxis"),
        ("VITAMIN_DEFICIENCY", "Carences en Vitamines/Minéraux", "pills.fill"),
        ("SLEEP_DISORDERS", "Troubles du Sommeil", "moon.zzz.fill"),
        ("TRANSIT_TROUBLES", "Troubles du Transit", "figure.walk")
    ]
    
    var body: some View {
        ModernOnboardingQuestionView(
            title: "Vos antécédents médicaux ?",
            subtitle: "Cochez les troubles actuels ou passés",
            buttonTitle: "Continuer",
            action: {
                viewModel.data.medicalHistory = Array(selectedConditions)
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    selection += 1
                }
            }
        ) {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(medicalConditions, id: \.0) { condition in
                        HStack {
                            Image(systemName: condition.2)
                                .font(.title3)
                                .foregroundColor(.white)
                                .frame(width: 30)
                            
                            Text(condition.1)
                                .font(.body)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .stroke(.white.opacity(0.3), lineWidth: 2)
                                    .frame(width: 24, height: 24)
                                
                                if selectedConditions.contains(condition.0) {
                                    Image(systemName: "checkmark")
                                        .font(.caption.bold())
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(16)
                        .background {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(selectedConditions.contains(condition.0) ? .white.opacity(0.2) : .white.opacity(0.1))
                        }
                        .onTapGesture {
                            if selectedConditions.contains(condition.0) {
                                selectedConditions.remove(condition.0)
                            } else {
                                selectedConditions.insert(condition.0)
                            }
                        }
                    }
                }
            }
            .frame(maxHeight: 450)
        }
        .onAppear {
            if let history = viewModel.data.medicalHistory {
                selectedConditions = Set(history)
            }
        }
    }
}

// MARK: - Combined Training Setup View (Location + Days)
struct TrainingSetupView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    @State private var selectedDays: Set<String> = []

    let locationOptions = [
        ("HOME", "À la maison", "house.fill"),
        ("GYM", "En salle", "dumbbell.fill"),
        ("OUTDOOR", "En extérieur", "leaf.fill"),
        ("MIXED", "Mixte", "arrow.triangle.2.circlepath")
    ]

    let dayOptions = ["LUN", "MAR", "MER", "JEU", "VEN", "SAM", "DIM"]

    var body: some View {
        ModernOnboardingQuestionView(
            title: "Configuration d'entraînement",
            subtitle: "Lieu et jours de pratique",
            buttonTitle: "Continuer",
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
                                    Text(option.1)
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
                                Text(day)
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
        .onAppear {
            if let days = viewModel.data.trainingDays {
                selectedDays = Set(days)
            }
        }
    }
}

// MARK: - Combined Diet Preferences View
struct DietPreferencesView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    @State private var selectedMeals: Set<String> = []

    let mealOptions = [
        ("MORNING", "Petit-déjeuner", "sunrise.fill"),
        ("NOON", "Déjeuner", "sun.max.fill"),
        ("EVENING", "Dîner", "moon.stars.fill")
    ]

    var body: some View {
        ModernOnboardingQuestionView(
            title: "Préférences alimentaires",
            subtitle: "Régime et habitudes de repas",
            buttonTitle: "Continuer",
            action: {
                viewModel.data.mealsPerDay = Array(selectedMeals).joined(separator: ",")
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    selection += 1
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
                                Text(meal.1)
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
        .onAppear {
            if let meals = viewModel.data.mealsPerDay?.components(separatedBy: ",") {
                selectedMeals = Set(meals)
            }
        }
    }
}

// MARK: - Combined Eating Habits View
struct EatingHabitsView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    @State private var selectedHabits: Set<String> = []

    let habitOptions = [
        ("LATE_EATING", "Je mange tard le soir", "moon.zzz.fill"),
        ("INSUFFICIENT_SLEEP", "Je ne dors pas assez", "bed.double.fill"),
        ("SWEETS_LOVER", "J'aime trop les sucreries", "birthday.cake.fill"),
        ("TOO_MUCH_SALT", "Je consomme beaucoup de sel", "shippingbox.fill"),
        ("DRINK_SODAS", "Je bois des sodas", "cup.and.saucer.fill"),
        ("SNACKING", "Je grignote souvent", "popcorn.fill")
    ]

    var body: some View {
        ModernOnboardingQuestionView(
            title: "Habitudes alimentaires",
            subtitle: "Sélectionnez celles qui s'appliquent",
            buttonTitle: "Continuer",
            action: {
                viewModel.data.badHabits = Array(selectedHabits)
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    selection += 1
                }
            }
        ) {
            ScrollView {
                VStack(spacing: 12) {
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
                                    .font(.title3)
                                    .frame(width: 30)
                                Text(habit.1)
                                    .font(.body)
                                Spacer()
                                Image(systemName: selectedHabits.contains(habit.0) ? "checkmark.circle.fill" : "circle")
                            }
                            .foregroundColor(.white)
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedHabits.contains(habit.0) ? Color.white.opacity(0.2) : Color.white.opacity(0.1))
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    Text("nutrition.onboarding.no_habits".localizedString)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.top, 8)
                }
            }
            .frame(maxHeight: 400)
        }
        .onAppear {
            if let habits = viewModel.data.badHabits {
                selectedHabits = Set(habits)
            }
        }
    }
}

// MARK: - Combined Food Consumption Grid View
struct FoodConsumptionGridView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int

    let foodCategories: [(key: String, emoji: String, name: String, binding: WritableKeyPath<OnboardingData, String?>)] = [
        ("vegetables", "🥦", "Légumes", \.vegetableConsumption),
        ("fruits", "🍎", "Fruits", \.fruitConsumption),
        ("meat", "🥩", "Viande", \.meatConsumption),
        ("fish", "🐟", "Poisson", \.fishConsumption),
        ("dairy", "🥛", "Laitiers", \.dairyConsumption),
        ("eggs", "🥚", "Œufs", \.eggConsumption),
        ("cereals", "🌾", "Céréales", \.cerealConsumption),
        ("starchy", "🍝", "Féculents", \.starchyFoodConsumption),
        ("sugary", "🍭", "Sucreries", \.sugaryFoodConsumption)
    ]

    let frequencyOptions = [
        ("EVERYDAY", "Quotidien", Color.green),
        ("1-2_WEEK", "1-2x/sem", Color.orange),
        ("NEVER", "Jamais", Color.red.opacity(0.7))
    ]

    var body: some View {
        ModernOnboardingQuestionView(
            title: "Consommation alimentaire",
            subtitle: "Sélectionnez votre fréquence pour chaque aliment",
            buttonTitle: "Continuer",
            action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    selection += 1
                }
            }
        ) {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(foodCategories, id: \.key) { category in
                        FoodCategoryRow(
                            emoji: category.emoji,
                            name: category.name,
                            selectedValue: Binding(
                                get: { viewModel.data[keyPath: category.binding] },
                                set: { viewModel.data[keyPath: category.binding] = $0 }
                            ),
                            options: frequencyOptions
                        )
                    }
                }
            }
            .frame(maxHeight: 450)
        }
    }
}

struct FoodCategoryRow: View {
    let emoji: String
    let name: String
    @Binding var selectedValue: String?
    let options: [(String, String, Color)]

    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Text(emoji)
                    .font(.title3)
                Text(name)
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            .frame(width: 100, alignment: .leading)

            HStack(spacing: 6) {
                ForEach(options, id: \.0) { option in
                    Button {
                        selectedValue = option.0
                    } label: {
                        Text(option.1)
                            .font(.caption2)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedValue == option.0 ? option.2 : Color.white.opacity(0.1))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

// MARK: - Combined Health Info View
struct HealthInfoView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int

    var body: some View {
        ModernOnboardingQuestionView(
            title: "Informations de santé",
            subtitle: "Ces informations nous aident à personnaliser vos recommandations",
            buttonTitle: "Continuer",
            action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    selection += 1
                }
            }
        ) {
            VStack(spacing: 20) {
                // Medication
                HealthToggleRow(
                    icon: "💊",
                    title: "Prenez-vous des médicaments régulièrement ?",
                    isSelected: Binding(
                        get: { viewModel.data.takesMedication ?? false },
                        set: { viewModel.data.takesMedication = $0 }
                    )
                )

                // Diabetes
                HealthToggleRow(
                    icon: "🩸",
                    title: "Avez-vous du diabète ?",
                    isSelected: Binding(
                        get: { viewModel.data.hasDiabetes ?? false },
                        set: { viewModel.data.hasDiabetes = $0 }
                    )
                )

                // Hormonal issues
                HealthToggleRow(
                    icon: "⚡️",
                    title: "Problèmes hormonaux ?",
                    isSelected: Binding(
                        get: { viewModel.data.hasHormonalIssues ?? false },
                        set: { viewModel.data.hasHormonalIssues = $0 }
                    )
                )
            }
        }
    }
}

struct HealthToggleRow: View {
    let icon: String
    let title: String
    @Binding var isSelected: Bool

    var body: some View {
        HStack {
            Text(icon)
                .font(.title2)

            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)

            Spacer()

            HStack(spacing: 8) {
                Button {
                    isSelected = true
                } label: {
                    Text("nutrition.onboarding.yes".localizedString)
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isSelected ? Color.green : Color.white.opacity(0.1))
                        )
                }
                .buttonStyle(.plain)

                Button {
                    isSelected = false
                } label: {
                    Text("nutrition.onboarding.no".localizedString)
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(!isSelected ? Color.red.opacity(0.7) : Color.white.opacity(0.1))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
}

// MARK: - Combined Medical History View
struct CombinedMedicalHistoryView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    @State private var selectedConditions: Set<String> = []

    let conditions = [
        ("ALLERGIES", "Allergies", "allergens"),
        ("LACTOSE_INTOLERANCE", "Intolérance lactose", "drop.fill"),
        ("ASTHMA", "Asthme", "lungs.fill"),
        ("DIGESTIVE_TROUBLES", "Troubles digestifs", "stomach"),
        ("FATIGUE", "Fatigue chronique", "bed.double.fill"),
        ("SKIN_TROUBLES", "Troubles cutanés", "hand.raised.fill"),
        ("JOINT_PAIN", "Douleurs articulaires", "figure.flexibility"),
        ("MIGRAINES", "Migraines", "bolt.heart.fill"),
        ("HYPERTENSION", "Hypertension", "heart.fill"),
        ("CHOLESTEROL", "Cholestérol élevé", "waveform.path.ecg"),
        ("SLEEP_DISORDERS", "Troubles du sommeil", "moon.zzz.fill")
    ]

    var body: some View {
        ModernOnboardingQuestionView(
            title: "Antécédents médicaux",
            subtitle: "Cochez les troubles actuels ou passés (optionnel)",
            buttonTitle: "Terminer",
            action: {
                viewModel.data.medicalHistory = Array(selectedConditions)
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    selection += 1
                }
            }
        ) {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(conditions, id: \.0) { condition in
                        Button {
                            if selectedConditions.contains(condition.0) {
                                selectedConditions.remove(condition.0)
                            } else {
                                selectedConditions.insert(condition.0)
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: condition.2)
                                    .font(.caption)
                                Text(condition.1)
                                    .font(.caption2)
                                    .lineLimit(1)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 8)
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
            .frame(maxHeight: 350)
        }
        .onAppear {
            if let history = viewModel.data.medicalHistory {
                selectedConditions = Set(history)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        OnboardingBackground(currentStep: 10, totalSteps: 15)
            .ignoresSafeArea()

        FoodConsumptionGridView(
            viewModel: OnboardingViewModel(),
            selection: .constant(11)
        )
    }
}
