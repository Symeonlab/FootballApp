//
//  KineView.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 14/11/2025.
//

import SwiftUI
import Combine

struct KineView: View {
    // 1. Use the new API-driven ViewModel
    @EnvironmentObject var viewModel: KineViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var selectedCategory: KineCategoryType = .mobility
    @State private var searchText: String = ""
    @State private var showOnlyFavorites: Bool = false
    @State private var sortMode: SortMode = .recommended
    @State private var showReels: Bool = false
    @State private var showQuickTips: Bool = false

    private enum SortMode: String, CaseIterable, Identifiable {
        case recommended, name
        var id: String { rawValue }
        var titleKey: LocalizedStringKey {
            switch self {
            case .recommended: return "kine.sort.recommended"
            case .name: return "kine.sort.name"
            }
        }
    }
    
    // 2. Get the correct exercise groups from the ViewModel
    private var exerciseGroups: [KineExerciseGroup] {
        switch selectedCategory {
        case .mobility:
            return viewModel.mobilityExerciseGroups
        case .strengthening:
            return viewModel.strengtheningExerciseGroups
        }
    }
    
    // 3. Apply filters (search, favorite, sort) to the groups
    private var filteredGroups: [KineExerciseGroup] {
        let groups = exerciseGroups
        
        var filtered: [KineExerciseGroup] = []
        
        for group in groups {
            var exercises = group.exercises
            
            // Apply favorites filter
            if showOnlyFavorites {
                exercises = exercises.filter { viewModel.isFavorite($0.id) }
            }
            
            // Apply search filter
            let trimmedSearch = searchText.trimmingCharacters(in: .whitespaces)
            if !trimmedSearch.isEmpty {
                exercises = exercises.filter {
                    $0.name.range(of: trimmedSearch, options: [.caseInsensitive, .diacriticInsensitive]) != nil
                }
            }
            
            // Apply sorting
            if sortMode == .name {
                exercises.sort { $0.name < $1.name }
            }
            
            if !exercises.isEmpty {
                filtered.append(KineExerciseGroup(id: group.id, category: group.category, exercises: exercises))
            }
        }
        return filtered
    }
    
    private var filteredExercises: [KineExercise] {
        filteredGroups.flatMap { $0.exercises }
    }

    // Computed property for total exercise count
    private var totalExercisesCount: Int {
        exerciseGroups.flatMap { $0.exercises }.count
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dark purple animated background
                DarkPurpleAnimatedBackground()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Compact search bar at top - push content higher
                    CompactSearchBar(
                        searchText: $searchText,
                        showOnlyFavorites: $showOnlyFavorites
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            // Minimal spacing at top
                            Color.clear.frame(height: 1)
                            
                            // Compact header
                            CompactRecoveryHeader(
                                favoriteCount: viewModel.favoriteIDs.count,
                                totalExercises: totalExercisesCount,
                                onQuickTipsPressed: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        showQuickTips = true
                                    }
                                }
                            )
                            .padding(.horizontal)
                            
                            // Action buttons row
                            HStack(spacing: 10) {
                                if !filteredExercises.isEmpty {
                                    RecoveryActionButton(
                                        icon: "play.fill",
                                        title: "Reels",
                                        startColor: .blue,
                                        endColor: .cyan,
                                        action: {
                                            withAnimation {
                                                showReels = true
                                            }
                                        }
                                    )
                                }
                                
                                RecoveryActionButton(
                                    icon: "arrow.up.arrow.down",
                                    title: "Sort",
                                    startColor: .purple,
                                    endColor: .pink,
                                    action: {}
                                )
                                
                                RecoveryActionButton(
                                    icon: "lightbulb.fill",
                                    title: "Tips",
                                    startColor: .orange,
                                    endColor: .yellow,
                                    action: {
                                        withAnimation {
                                            showQuickTips = true
                                        }
                                    }
                                )
                            }
                            .padding(.horizontal)
                            
                            // Category picker
                            ModernCategoryPicker(selectedCategory: $selectedCategory)
                                .padding(.horizontal)
                            
                            // Content
                            contentSection
                                .padding(.horizontal)
                            
                            // Bottom padding for tab bar
                            Color.clear.frame(height: 140)
                        }
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .navigationTitle("Recovery - Dipodi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Recovery")
                        .font(.headline.bold())
                        .foregroundColor(.primary)
                }
            }
            .fullScreenCover(isPresented: $showReels) {
                KineReelsView(viewModel: viewModel, exercises: filteredExercises.toAPIExercises())
                    .ignoresSafeArea()
            }
            .sheet(isPresented: $showQuickTips) {
                EnhancedRecoveryTipsView()
            }
        }
        .navigationViewStyle(.stack)
    }
    
    // MARK: - Body Components
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.95, green: 0.96, blue: 0.98),
                Color(red: 0.92, green: 0.94, blue: 0.98),
                Color(red: 0.94, green: 0.95, blue: 0.97)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var headerSection: some View {
        EnhancedRecoveryHeaderView(
            favoriteCount: viewModel.favoriteIDs.count,
            totalExercises: totalExercisesCount,
            onQuickTipsPressed: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showQuickTips = true
                }
            }
        )
        .padding()
    }
    
    private var actionButtonsSection: some View {
        HStack(spacing: 12) {
            if !filteredExercises.isEmpty {
                reelsButton
            }
            
            Spacer()
            
            sortMenu
        }
        .padding(.horizontal)
        .padding(.bottom, 12)
    }
    
    private var reelsButton: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showReels = true
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "play.rectangle.on.rectangle.fill")
                    .font(.body.weight(.semibold))
                Text("kine.reels")
                    .font(.subheadline.weight(.semibold))
            }
        }
        .buttonStyle(.gradientGlass(from: .blue, to: .cyan))
    }
    
    private var sortMenu: some View {
        Menu {
            Picker("kine.sort", selection: $sortMode) {
                ForEach(SortMode.allCases) { mode in
                    Label(mode.titleKey, systemImage: mode == .recommended ? "star.fill" : "textformat.abc")
                        .tag(mode)
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.body.weight(.semibold))
                Text("Sort")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.ultraThinMaterial)
                    
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            }
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        }
    }
    
    private var categoryPickerSection: some View {
        EnhancedKineCategoryPicker(selectedCategory: $selectedCategory)
            .padding(.horizontal)
            .padding(.bottom, 12)
    }
    
    private var searchBarSection: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                    .font(.body)
                
                TextField("Search exercises", text: $searchText)
                    .textFieldStyle(.plain)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            
            Button(action: { 
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showOnlyFavorites.toggle()
                }
            }) {
                Image(systemName: showOnlyFavorites ? "heart.fill" : "heart")
                    .font(.title3)
                    .foregroundStyle(showOnlyFavorites ? .red : .secondary)
                    .frame(width: 48, height: 48)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
    
    @ViewBuilder
    private var contentSection: some View {
        if viewModel.isLoading && filteredGroups.isEmpty {
            EnhancedKineLoadingView()
                .frame(maxHeight: .infinity)
        } else if filteredGroups.isEmpty {
            EnhancedEmptyRecoveryState(
                category: selectedCategory,
                isFiltered: showOnlyFavorites || !searchText.isEmpty
            )
            .frame(maxHeight: .infinity)
        } else {
            exerciseListView
        }
    }
    
    private var exerciseListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(Array(filteredGroups.enumerated()), id: \.element.id) { index, group in
                    VStack(alignment: .leading, spacing: 12) {
                        // Group Header
                        Text(group.groupName)
                            .font(.title3.bold())
                            .foregroundColor(Color.theme.textPrimary)
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        // Exercises
                        ForEach(Array(group.exercises.enumerated()), id: \.element.id) { exerciseIndex, exercise in
                            EnhancedExerciseCard(
                                exercise: exercise,
                                isFavorite: viewModel.isFavorite(exerciseID: exercise.id),
                                onFavoriteTap: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        viewModel.toggleFavorite(exerciseID: exercise.id)
                                    }
                                }
                            )
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
    }
}

// MARK: - Recovery Header View
private struct RecoveryHeaderView: View {
    let favoriteCount: Int
    let totalExercises: Int
    let onQuickTipsPressed: () -> Void
    
    @State private var animateBadge = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Main Header
            HStack(alignment: .center, spacing: 16) {
                // Icon with gradient
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.theme.primary, Color.theme.accent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                        .shadow(color: Color.theme.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("kine.recovery_hub")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color.theme.textPrimary)
                    
                    Text(String(format: NSLocalizedString("kine.exercises_available", comment: ""), totalExercises))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Quick Tips Button with pulse effect
                Button(action: onQuickTipsPressed) {
                    ZStack {
                        Circle()
                            .fill(Color.theme.primary.opacity(0.15))
                            .frame(width: 48, height: 48)
                            .scaleEffect(animateBadge ? 1.2 : 1.0)
                            .opacity(animateBadge ? 0 : 1)
                        
                        Image(systemName: "lightbulb.fill")
                            .font(.title3)
                            .foregroundColor(Color.theme.primary)
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(Color.theme.primary.opacity(0.1))
                            )
                    }
                }
            }
            
            // Stats Row
            HStack(spacing: 12) {
                // Favorites Badge
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .font(.subheadline)
                        .foregroundColor(.yellow)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(favoriteCount)")
                            .font(.headline.bold())
                            .foregroundColor(Color.theme.textPrimary)
                        Text("kine.favorites")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.theme.surface)
                        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
                )
                
                // Total Exercises Badge
                HStack(spacing: 8) {
                    Image(systemName: "list.bullet.rectangle")
                        .font(.subheadline)
                        .foregroundColor(Color.theme.primary)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(totalExercises)")
                            .font(.headline.bold())
                            .foregroundColor(Color.theme.textPrimary)
                        Text("kine.total")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.theme.surface)
                        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
                )
                
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.theme.background)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.theme.surface, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.06), radius: 15, x: 0, y: 8)
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                animateBadge = true
            }
        }
    }
}

// MARK: - Empty Recovery State
private struct EmptyRecoveryState: View {
    let category: KineCategoryType
    let isFiltered: Bool
    @State private var animateIcon = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Animated Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.theme.primary.opacity(0.1),
                                Color.theme.accent.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                    .scaleEffect(animateIcon ? 1.05 : 1.0)
                    .opacity(animateIcon ? 0.8 : 1.0)
                
                Image(systemName: category == .mobility ? "figure.cooldown" : "dumbbell.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.theme.primary, Color.theme.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(animateIcon ? 1.0 : 0.95)
            }
            
            VStack(spacing: 12) {
                Text(isFiltered ? "kine.no_matching_exercises" : "kine.no_exercises_found")
                    .font(.title3.bold())
                    .foregroundColor(Color.theme.textPrimary)
                
                Text(isFiltered ? "kine.adjust_filters" : "kine.check_back_later")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            if isFiltered {
                Button {
                    // This would need to be passed in or handled via notification
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("kine.clear_filters")
                    }
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Color.theme.primary)
                            .shadow(color: Color.theme.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                    )
                }
            }
        }
        .padding()
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                animateIcon = true
            }
        }
    }
}

// MARK: - Recovery Tips View
struct RecoveryTipsView: View {
    @Environment(\.dismiss) private var dismiss
    
    let tips = [
        RecoveryTip(
            icon: "moon.fill",
            title: NSLocalizedString("recovery.tips.sleep.title", comment: ""),
            description: NSLocalizedString("recovery.tips.sleep.description", comment: ""),
            color: .indigo,
            benefit: "7-9 hours per night"
        ),
        RecoveryTip(
            icon: "drop.fill",
            title: NSLocalizedString("recovery.tips.hydration.title", comment: ""),
            description: NSLocalizedString("recovery.tips.hydration.description", comment: ""),
            color: .blue,
            benefit: "2-3 liters daily"
        ),
        RecoveryTip(
            icon: "figure.cooldown",
            title: NSLocalizedString("recovery.tips.active.title", comment: ""),
            description: NSLocalizedString("recovery.tips.active.description", comment: ""),
            color: .green,
            benefit: "Light movement"
        ),
        RecoveryTip(
            icon: "leaf.fill",
            title: NSLocalizedString("recovery.tips.nutrition.title", comment: ""),
            description: NSLocalizedString("recovery.tips.nutrition.description", comment: ""),
            color: .orange,
            benefit: "Protein & carbs"
        ),
        RecoveryTip(
            icon: "wind",
            title: NSLocalizedString("recovery.tips.breathing.title", comment: ""),
            description: NSLocalizedString("recovery.tips.breathing.description", comment: ""),
            color: .purple,
            benefit: "5-10 minutes"
        ),
        RecoveryTip(
            icon: "snowflake",
            title: NSLocalizedString("recovery.tips.iceheat.title", comment: ""),
            description: NSLocalizedString("recovery.tips.iceheat.description", comment: ""),
            color: .cyan,
            benefit: "15-20 minutes"
        )
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Card
                    VStack(spacing: 12) {
                        HStack {
                            Spacer()
                            Button(action: { dismiss() }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.theme.primary, Color.theme.accent],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                                .shadow(color: Color.theme.primary.opacity(0.3), radius: 15, x: 0, y: 8)
                            
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                        }
                        
                        Text("Recovery Tips")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color.theme.textPrimary)
                        
                        Text("Optimize your recovery process")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 24)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.theme.surface)
                            .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 8)
                    )
                    .padding(.horizontal)
                    
                    // Tips Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(tips) { tip in
                            RecoveryTipCard(tip: tip)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color.theme.background.ignoresSafeArea())
            .navigationTitle("kine.recovery_tips")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct RecoveryTip: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let color: Color
    let benefit: String
}

struct RecoveryTipCard: View {
    let tip: RecoveryTip
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(tip.color.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Image(systemName: tip.icon)
                    .font(.title2)
                    .foregroundColor(tip.color)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(tip.title)
                    .font(.headline.bold())
                    .foregroundColor(Color.theme.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)
                
                Text(tip.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Benefit Badge
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption2)
                    Text(tip.benefit)
                        .font(.caption2.bold())
                }
                .foregroundColor(tip.color)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(tip.color.opacity(0.1))
                )
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.theme.surface)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
        }
    }
}

private struct KineCategoryPicker: View {
    @Binding var selectedCategory: KineCategoryType
    @Namespace private var animation

    var body: some View {
        HStack(spacing: 12) {
            ForEach(KineCategoryType.allCases, id: \.self) { category in
                CategoryButton(
                    category: category,
                    isSelected: selectedCategory == category,
                    namespace: animation
                ) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        selectedCategory = category
                    }
                }
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.theme.surface)
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
        )
    }
}

private struct CategoryButton: View {
    let category: KineCategoryType
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: category == .mobility ? "figure.cooldown" : "dumbbell.fill")
                    .font(.subheadline.bold())
                Text(category.titleKey)
                    .font(.subheadline.bold())
            }
            .foregroundColor(isSelected ? .white : Color.theme.textPrimary)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.theme.primary, Color.theme.accent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .matchedGeometryEffect(id: "categoryBG", in: namespace)
                        .shadow(color: Color.theme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

private struct KineSearchBar: View {
    @Binding var searchText: String
    @Binding var showOnlyFavorites: Bool
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Search Field
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(isFocused ? Color.theme.primary : .secondary)
                    .font(.body.weight(.semibold))
                
                TextField("kine.search.placeholder", text: $searchText)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .focused($isFocused)
                
                if !searchText.isEmpty {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            searchText = ""
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.theme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(
                                isFocused ? Color.theme.primary.opacity(0.5) : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
            
            // Favorites Toggle
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showOnlyFavorites.toggle()
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(showOnlyFavorites ? Color.yellow.opacity(0.2) : Color.theme.surface)
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: showOnlyFavorites ? "star.fill" : "star")
                        .font(.body.weight(.semibold))
                        .foregroundColor(showOnlyFavorites ? .yellow : .secondary)
                }
            }
            .buttonStyle(.plain)
        }
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}

private struct ExerciseListView: View {
    @ObservedObject var viewModel: KineViewModel
    let groups: [KineExerciseGroup]

    var body: some View {
        List {
            // FIX: Use groups (non-binding) for display-only ForEach
            ForEach(groups, id: \.id) { group in
                Section {
                    ForEach(group.exercises, id: \.id) { exercise in
                        ExerciseLinkRow(viewModel: viewModel, exercise: exercise)
                    }
                } header: {
                    Text(group.groupName.uppercased())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

private struct ExerciseLinkRow: View {
    @ObservedObject var viewModel: KineViewModel
    let exercise: KineExercise

    var body: some View {
        let isFav = viewModel.isFavorite(exerciseID: exercise.id)
        return NavigationLink(destination: KineExerciseVideoView(exercise: exercise)) {
            ExerciseRow(name: exercise.name, isFavorite: isFav)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .none) {
                viewModel.toggleFavorite(exerciseID: exercise.id)
            } label: {
                Label(isFav ? "kine.unfavorite" : "kine.favorite", systemImage: isFav ? "star.slash" : "star")
            }.tint(.yellow)
        }
        .contextMenu {
            Button(isFav ? NSLocalizedString("kine.remove_favorite", comment: "") : NSLocalizedString("kine.add_favorite", comment: "")) {
                viewModel.toggleFavorite(exerciseID: exercise.id)
            }
        }
    }
}

private struct ExerciseRow: View {
    let name: String
    let isFavorite: Bool
    @State private var isPressed = false

    var body: some View {
        HStack(spacing: 16) {
            // Exercise Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.theme.primary.opacity(0.1),
                                Color.theme.accent.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.title3)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.theme.primary, Color.theme.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            // Exercise Info
            VStack(alignment: .leading, spacing: 6) {
                Text(name)
                    .font(.body.weight(.semibold))
                    .foregroundColor(Color.theme.textPrimary)
                    .lineLimit(2)
                
                HStack(spacing: 6) {
                    Image(systemName: "play.circle.fill")
                        .font(.caption)
                    Text("kine.guided_video")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }
            
            Spacer(minLength: 0)
            
            // Status Indicators
            HStack(spacing: 12) {
                if isFavorite {
                    Image(systemName: "star.fill")
                        .font(.subheadline)
                        .foregroundColor(.yellow)
                        .transition(.scale.combined(with: .opacity))
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(Color.theme.background)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
    }
}

#Preview {
    @Previewable @StateObject var kineVM = KineViewModel()
    @Previewable @StateObject var authVM = AuthViewModel()
    @Previewable @StateObject var langManager = LanguageManager()
    @Previewable @StateObject var themeManager = ThemeManager()
    
    return KineView()
        .environmentObject(kineVM)
        .environmentObject(authVM)
        .environmentObject(langManager)
        .environmentObject(themeManager)
        .preferredColorScheme(.dark)
}

// MARK: - Enhanced Kine Components

// Enhanced Recovery Header
private struct EnhancedRecoveryHeaderView: View {
    let favoriteCount: Int
    let totalExercises: Int
    let onQuickTipsPressed: () -> Void
    
    @State private var animateBadge = false
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .center, spacing: 16) {
                // Icon with animated gradient
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.theme.primary.opacity(0.3), Color.theme.accent.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 66, height: 66)
                        .scaleEffect(pulseScale)
                        .blur(radius: 8)
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.theme.primary, Color.theme.accent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .shadow(color: Color.theme.primary.opacity(0.4), radius: 12, x: 0, y: 6)
                    
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("kine.recovery_hub")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.theme.textPrimary, Color.theme.textPrimary.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text(String(format: NSLocalizedString("kine.exercises_available", comment: ""), totalExercises))
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Quick Tips Button with advanced animation
                Button(action: {
                    onQuickTipsPressed()
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.theme.primary.opacity(0.15))
                            .frame(width: 52, height: 52)
                            .scaleEffect(animateBadge ? 1.3 : 1.0)
                            .opacity(animateBadge ? 0 : 1)
                        
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.theme.primary.opacity(0.15), Color.theme.accent.opacity(0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "lightbulb.fill")
                            .font(.title3)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.theme.primary, Color.theme.accent],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
            }
            
            // Enhanced Stats Row
            HStack(spacing: 12) {
                EnhancedStatBadge(
                    icon: "star.fill",
                    value: "\(favoriteCount)",
                    label: "kine.favorites",
                    color: .yellow,
                    gradient: [.yellow, .orange]
                )
                
                EnhancedStatBadge(
                    icon: "list.bullet.rectangle.fill",
                    value: "\(totalExercises)",
                    label: "kine.total",
                    color: Color.theme.primary,
                    gradient: [Color.theme.primary, Color.theme.accent]
                )
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.theme.primary.opacity(0.2), Color.theme.accent.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 10)
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                animateBadge = true
                pulseScale = 1.15
            }
        }
    }
}

struct EnhancedStatBadge: View {
    let icon: String
    let value: String
    let label: LocalizedStringKey
    let color: Color
    let gradient: [Color]
    
    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradient.map { $0.opacity(0.2) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color.theme.textPrimary)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.theme.background)
                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
        )
    }
}

// Enhanced Category Picker
struct EnhancedKineCategoryPicker: View {
    @Binding var selectedCategory: KineCategoryType
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach([KineCategoryType.mobility, KineCategoryType.strengthening], id: \.self) { category in
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selectedCategory = category
                    }
                    let generator = UIImpactFeedbackGenerator(style: .soft)
                    generator.impactOccurred()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: category == .mobility ? "figure.flexibility" : "dumbbell.fill")
                            .font(.subheadline.weight(.semibold))
                        
                        Text(category == .mobility ? "Mobility" : "Strengthening")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundColor(selectedCategory == category ? .white : Color.theme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        Group {
                            if selectedCategory == category {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.theme.primary, Color.theme.accent],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: Color.theme.primary.opacity(0.4), radius: 10, x: 0, y: 5)
                                    .matchedGeometryEffect(id: "category_bg", in: animation)
                            }
                        }
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.theme.surface)
                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
        )
    }
}

// Enhanced Search Bar
struct EnhancedKineSearchBar: View {
    @Binding var searchText: String
    @Binding var showOnlyFavorites: Bool
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Search Field
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(isSearchFocused ? Color.theme.primary : .secondary)
                    .font(.subheadline)
                
                TextField("Search exercises...", text: $searchText)
                    .font(.subheadline)
                    .focused($isSearchFocused)
                
                if !searchText.isEmpty {
                    Button(action: {
                        withAnimation {
                            searchText = ""
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.theme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(
                                isSearchFocused ? 
                                LinearGradient(colors: [Color.theme.primary.opacity(0.5), Color.theme.accent.opacity(0.5)], startPoint: .leading, endPoint: .trailing) :
                                LinearGradient(colors: [.clear, .clear], startPoint: .leading, endPoint: .trailing),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: isSearchFocused ? Color.theme.primary.opacity(0.2) : .clear, radius: 10, x: 0, y: 5)
            )
            
            // Favorites Filter
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showOnlyFavorites.toggle()
                }
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            }) {
                Image(systemName: showOnlyFavorites ? "star.fill" : "star")
                    .font(.title3)
                    .foregroundColor(showOnlyFavorites ? .yellow : Color.theme.textSecondary)
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(showOnlyFavorites ? Color.yellow.opacity(0.15) : Color.theme.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(showOnlyFavorites ? Color.yellow.opacity(0.3) : Color.clear, lineWidth: 2)
                            )
                            .shadow(color: showOnlyFavorites ? Color.yellow.opacity(0.3) : .black.opacity(0.04), radius: 8, x: 0, y: 4)
                    )
            }
        }
    }
}

// Enhanced Loading View
struct EnhancedKineLoadingView: View {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                ForEach(0..<3) { index in
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color.theme.primary.opacity(0.3), Color.theme.accent.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 4
                        )
                        .frame(width: 90 + CGFloat(index * 25), height: 90 + CGFloat(index * 25))
                        .rotationEffect(.degrees(rotation + Double(index * 120)))
                }
                
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.theme.primary, Color.theme.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(scale)
            }
            
            VStack(spacing: 8) {
                Text("Loading Exercises")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(Color.theme.textPrimary)
                
                Text("Preparing your recovery routines...")
                    .font(.subheadline)
                    .foregroundColor(Color.theme.textSecondary)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                scale = 1.2
            }
        }
    }
}

// Enhanced Empty State
private struct EnhancedEmptyRecoveryState: View {
    let category: KineCategoryType
    let isFiltered: Bool
    @State private var animateIcon = false
    
    var body: some View {
        VStack(spacing: 32) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.theme.primary.opacity(0.15),
                                Color.theme.accent.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                    .scaleEffect(animateIcon ? 1.1 : 1.0)
                
                Image(systemName: isFiltered ? "magnifyingglass" : "figure.wave")
                    .font(.system(size: 60, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.theme.primary, Color.theme.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 12) {
                Text(isFiltered ? "No Results" : "No Exercises")
                    .font(.title2.bold())
                    .foregroundColor(Color.theme.textPrimary)
                
                Text(isFiltered ? 
                    "Try adjusting your filters or search" :
                    "Exercises for \(category == .mobility ? "Mobility" : "Strengthening") will appear here"
                )
                .font(.body)
                .foregroundColor(Color.theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                animateIcon = true
            }
        }
    }
}

// Enhanced Exercise List (inlined in main view)

// Enhanced Exercise Card
struct EnhancedExerciseCard: View {
    let exercise: KineExercise
    let isFavorite: Bool
    let onFavoriteTap: () -> Void
    
    @State private var isPressed = false
    @State private var showVideo = false
    
    var body: some View {
        Button(action: {
            showVideo = true
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }) {
            HStack(spacing: 16) {
                // Video Thumbnail/Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.theme.primary.opacity(0.2), Color.theme.accent.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                
                // Exercise Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(exercise.name)
                        .font(.headline)
                        .foregroundColor(Color.theme.textPrimary)
                        .lineLimit(2)
                    
                    HStack(spacing: 8) {
                        Label(exercise.category, systemImage: "tag.fill")
                            .font(.caption)
                            .foregroundColor(Color.theme.textSecondary)
                        
                        if !exercise.sub_category.isEmpty {
                            Text("•")
                                .foregroundColor(Color.theme.textSecondary)
                            Text(exercise.sub_category)
                                .font(.caption)
                                .foregroundColor(Color.theme.textSecondary)
                        }
                    }
                }
                
                Spacer()
                
                // Favorite Button
                Button(action: {
                    onFavoriteTap()
                }) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .font(.title3)
                        .foregroundColor(isFavorite ? .yellow : Color.theme.textSecondary)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(isFavorite ? Color.yellow.opacity(0.15) : Color.theme.background)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.theme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.theme.primary.opacity(0.1), Color.theme.accent.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(.plain)
        .pressEvents(onPress: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
        }, onRelease: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = false
            }
        })
        .fullScreenCover(isPresented: $showVideo) {
            KineExerciseVideoView(exercise: exercise)
        }
    }
}

// Press Events Helper
extension View {
    func pressEvents(onPress: @escaping (() -> Void), onRelease: @escaping (() -> Void)) -> some View {
        self.modifier(PressActionsModifier(onPress: onPress, onRelease: onRelease))
    }
}

struct PressActionsModifier: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        onPress()
                    }
                    .onEnded { _ in
                        onRelease()
                    }
            )
    }
}

// MARK: - Modern Recovery Components

struct CompactSearchBar: View {
    @Binding var searchText: String
    @Binding var showOnlyFavorites: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                    .font(.body)
                
                TextField("Search exercises", text: $searchText)
                    .textFieldStyle(.plain)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            
            Button(action: { 
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showOnlyFavorites.toggle()
                }
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            }) {
                Image(systemName: showOnlyFavorites ? "heart.fill" : "heart")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(showOnlyFavorites ? .red : .secondary)
                    .frame(width: 50, height: 50)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            }
        }
    }
}

struct CompactRecoveryHeader: View {
    let favoriteCount: Int
    let totalExercises: Int
    let onQuickTipsPressed: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Favorites count
                HStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(favoriteCount)")
                            .font(.title2.bold())
                        Text("Favorites")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                
                // Total exercises
                HStack(spacing: 8) {
                    Image(systemName: "figure.strengthtraining.functional")
                        .foregroundColor(.blue)
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(totalExercises)")
                            .font(.title2.bold())
                        Text("Exercises")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            }
        }
    }
}

struct RecoveryActionButton: View {
    let icon: String
    let title: String
    let startColor: Color
    let endColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [startColor, endColor],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .shadow(color: startColor.opacity(0.4), radius: 10, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}

struct ModernCategoryPicker: View {
    @Binding var selectedCategory: KineCategoryType
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(KineCategoryType.allCases, id: \.self) { category in
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selectedCategory = category
                    }
                    let generator = UIImpactFeedbackGenerator(style: .soft)
                    generator.impactOccurred()
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: category == .mobility ? "figure.flexibility" : "figure.strengthtraining.functional")
                            .font(.system(size: 24, weight: selectedCategory == category ? .semibold : .regular))
                        
                        Text(category == .mobility ? "Mobility" : "Strengthening")
                            .font(.system(size: 13, weight: selectedCategory == category ? .semibold : .regular))
                    }
                    .foregroundColor(selectedCategory == category ? .white : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        Group {
                            if selectedCategory == category {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue, .cyan],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: .blue.opacity(0.4), radius: 10, x: 0, y: 6)
                                    .matchedGeometryEffect(id: "category_bg", in: animation)
                            }
                        }
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 6)
    }
}

// Enhanced Recovery Tips View
struct EnhancedRecoveryTipsView: View {
    @Environment(\.dismiss) private var dismiss
    
    let tips = [
        ("figure.walk", "Stay Active", "Light movement aids recovery"),
        ("drop.fill", "Hydrate", "Drink water before, during, and after"),
        ("bed.double.fill", "Rest Well", "Quality sleep accelerates healing"),
        ("fork.knife", "Eat Protein", "Support muscle repair with nutrition"),
        ("figure.cooldown", "Stretch Daily", "Maintain flexibility and prevent injury"),
        ("heart.fill", "Listen to Your Body", "Rest when you need it")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Close Button
                    HStack {
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                    }
                    
                    ForEach(tips, id: \.0) { tip in
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.theme.primary.opacity(0.2), Color.theme.accent.opacity(0.15)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 56, height: 56)
                                
                                Image(systemName: tip.0)
                                    .font(.title3)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color.theme.primary, Color.theme.accent],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(tip.1)
                                    .font(.headline)
                                    .foregroundColor(Color.theme.textPrimary)
                                
                                Text(tip.2)
                                    .font(.subheadline)
                                    .foregroundColor(Color.theme.textSecondary)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.theme.surface)
                                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
                        )
                    }
                }
                .padding()
            }
            .background(Color.theme.background.ignoresSafeArea())
            .navigationTitle("Recovery Tips")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}




