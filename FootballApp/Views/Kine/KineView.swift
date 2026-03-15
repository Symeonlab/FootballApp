//
//  KineView.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 14/11/2025.
//

import SwiftUI
import Combine
import os.log

struct KineView: View {
    // 1. Use the new API-driven ViewModel
    @EnvironmentObject var viewModel: KineViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    // Logger for KineView
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.app", category: "KineView")

    @State private var selectedCategory: KineCategoryType = .mobility
    @State private var searchText: String = ""
    @State private var showOnlyFavorites: Bool = false
    @State private var sortMode: SortMode = .recommended
    @State private var showReels: Bool = false
    @State private var showQuickTips: Bool = false
    @State private var selectedStoryExercise: KineExercise?
    @State private var showStoryDetail: Bool = false
    @State private var cachedRecommendedExercises: [KineExercise] = []

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

    // Recommended exercises - favorites + random selection for variety
    // Cached to avoid re-randomizing on every state update
    private func updateRecommendedExercises() {
        let allExercises = viewModel.allExercises
        guard !allExercises.isEmpty else {
            cachedRecommendedExercises = []
            return
        }

        // Get favorites first
        let favorites = allExercises.filter { viewModel.isFavorite($0.id) }

        // Get some random exercises for variety (excluding favorites)
        let nonFavorites = allExercises.filter { !viewModel.isFavorite($0.id) }
        let randomPicks = nonFavorites.shuffled().prefix(max(0, 8 - favorites.count))

        // Combine and limit to 8 items
        cachedRecommendedExercises = Array((favorites + randomPicks).prefix(8))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Dark purple animated background
                DarkPurpleAnimatedBackground()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Compact search bar with sort integrated
                    HStack(spacing: 12) {
                        CompactSearchBar(
                            searchText: $searchText,
                            showOnlyFavorites: $showOnlyFavorites
                        )

                        // Sort button integrated next to search
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                sortMode = sortMode == .recommended ? .name : .recommended
                            }
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                        }) {
                            Image(systemName: sortMode == .recommended ? "arrow.up.arrow.down" : "textformat.abc")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(sortMode == .name ? Color.appTheme.primary : .secondary)
                                .frame(width: 50, height: 50)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 4)

                    // Category picker directly below search
                    ModernCategoryPicker(selectedCategory: $selectedCategory)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            // Recommended Exercises Stories Row
                            if !cachedRecommendedExercises.isEmpty {
                                RecommendedExercisesRow(
                                    exercises: cachedRecommendedExercises,
                                    favorites: viewModel.favoriteIDs,
                                    onExerciseTap: { exercise in
                                        selectedStoryExercise = exercise
                                        showStoryDetail = true
                                    },
                                    onPlayAllTap: {
                                        showReels = true
                                    }
                                )
                            }

                            // Content (exercise groups list)
                            contentSection
                                .padding(.horizontal)

                            // Bottom padding for tab bar + FAB
                            Color.clear.frame(height: 160)
                        }
                    }
                    .scrollIndicators(.hidden)
                }

                // Floating Action Button for Reels - bottom right
                if !filteredExercises.isEmpty {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            GradientFloatingActionButton(
                                icon: "play.rectangle.on.rectangle.fill",
                                label: "kine.reels".localizedString,
                                gradientColors: [.blue, .cyan],
                                action: {
                                    showReels = true
                                }
                            )
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("kine.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("kine.title".localizedString)
                        .font(.headline.bold())
                        .foregroundColor(.primary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation {
                            showQuickTips = true
                        }
                    } label: {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.orange)
                    }
                }
            }
            .fullScreenCover(isPresented: $showReels) {
                KineReelsView(viewModel: viewModel, exercises: filteredExercises.toAPIExercises())
                    .ignoresSafeArea()
            }
            .sheet(isPresented: $showQuickTips) {
                EnhancedRecoveryTipsView()
            }
            .fullScreenCover(item: $selectedStoryExercise) { exercise in
                KineExerciseVideoView(exercise: exercise)
            }
            .task {
                logger.info("👁️ KineView: Task triggered")

                // Only fetch if no data
                if viewModel.allExercises.isEmpty {
                    logger.info("📥 KineView: Fetching kine data...")
                    await viewModel.fetchKineDataAsync()
                }

                // Cache recommended exercises once on appear
                if cachedRecommendedExercises.isEmpty {
                    updateRecommendedExercises()
                }

                // Log current state
                logger.info("📊 KineView: Current data state:")
                logger.info("   - Categories: \(viewModel.categories.count)")
                logger.info("   - Total exercises: \(viewModel.allExercises.count)")
                logger.info("   - Exercise groups: \(viewModel.exerciseGroups.count)")
                logger.info("   - Favorites: \(viewModel.favoriteIDs.count)")
                logger.info("   - Selected category: \(String(describing: selectedCategory))")

                // Log if data is shown correctly
                if !viewModel.allExercises.isEmpty {
                    logger.info("✅ KineView: Exercises loaded and displayed successfully")

                    // Log category breakdown
                    for group in exerciseGroups {
                        logger.debug("   - \(group.groupName): \(group.exercises.count) exercises")
                    }
                } else if let error = viewModel.errorMessage {
                    logger.error("❌ KineView: Error state - \(error)")
                } else {
                    logger.warning("⚠️ KineView: No exercises loaded")
                }
            }
            .refreshable {
                logger.info("🔄 KineView: Pull-to-refresh triggered")
                await viewModel.fetchKineDataAsync()
            }
            .onChange(of: viewModel.allExercises) { oldValue, newValue in
                logger.info("🔄 KineView: Exercises changed - \(oldValue.count) -> \(newValue.count)")

                if !newValue.isEmpty {
                    logger.info("✅ KineView: Successfully displaying \(newValue.count) exercises across \(viewModel.categories.count) categories")
                }

                // Refresh cached recommended exercises when data changes
                updateRecommendedExercises()
            }
            .onChange(of: viewModel.isLoading) { oldValue, newValue in
                logger.info("⏳ KineView: Loading state changed - \(oldValue) -> \(newValue)")
            }
            .onChange(of: viewModel.errorMessage) { oldValue, newValue in
                if let error = newValue {
                    logger.error("❌ KineView: Error occurred - \(error)")
                }
            }
        }

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
                Text("kine.sort".localizedString)
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
                
                TextField("kine.search_exercises".localizedString, text: $searchText)
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
        LazyVStack(spacing: 16) {
            ForEach(Array(filteredGroups.enumerated()), id: \.element.id) { index, group in
                VStack(alignment: .leading, spacing: 12) {
                    // Group Header
                    Text(group.groupName)
                        .font(.title3.bold())
                        .foregroundColor(Color.theme.textPrimary)
                        .padding(.top, 8)

                    // Exercises
                    ForEach(Array(group.exercises.enumerated()), id: \.element.id) { exerciseIndex, exercise in
                        EnhancedExerciseCard(
                            exercise: exercise,
                            isFavorite: viewModel.isFavorite(exerciseID: exercise.id),
                            onFavoriteTap: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    viewModel.toggleFavorite(exerciseID: exercise.id)
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                }
                            }
                        )
                    }
                }
            }
        }
        .padding(.vertical)
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
        NavigationStack {
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
                        
                        Text("kine.recovery_tips".localizedString)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color.theme.textPrimary)

                        Text("kine.optimize_recovery".localizedString)
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
                        
                        Text(category == .mobility ? "kine.mobility".localizedString : "kine.strengthening".localizedString)
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
                Text("kine.loading_exercises".localizedString)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(Color.theme.textPrimary)

                Text("kine.preparing_routines".localizedString)
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
                Text(isFiltered ? "kine.no_results".localizedString : "kine.no_exercises".localizedString)
                    .font(.title2.bold())
                    .foregroundColor(Color.theme.textPrimary)

                Text(isFiltered ?
                    "kine.try_adjusting_filters".localizedString :
                    String(format: "kine.exercises_will_appear".localizedString, category == .mobility ? "kine.mobility".localizedString : "kine.strengthening".localizedString)
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

// Enhanced Exercise Card with Video Thumbnail
struct EnhancedExerciseCard: View {
    let exercise: KineExercise
    let isFavorite: Bool
    let onFavoriteTap: () -> Void

    @State private var isPressed = false
    @State private var showVideo = false

    // Extract YouTube video ID for thumbnail
    private var youtubeVideoID: String? {
        guard let urlString = exercise.video_url, !urlString.isEmpty else { return nil }

        // Handle youtu.be/VIDEO_ID format
        if urlString.contains("youtu.be/") {
            if let url = URL(string: urlString) {
                return url.lastPathComponent
            }
        }

        // Handle youtube.com/shorts/VIDEO_ID format
        if urlString.contains("/shorts/") {
            if let url = URL(string: urlString) {
                return url.lastPathComponent
            }
        }

        // Handle youtube.com/watch?v=VIDEO_ID format
        if let url = URL(string: urlString),
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems,
           let videoID = queryItems.first(where: { $0.name == "v" })?.value {
            return videoID
        }

        // Handle youtube.com/embed/VIDEO_ID format
        if urlString.contains("/embed/") {
            if let url = URL(string: urlString) {
                return url.lastPathComponent
            }
        }

        return nil
    }

    // YouTube thumbnail URL
    private var thumbnailURL: URL? {
        guard let videoID = youtubeVideoID else { return nil }
        // Use maxresdefault for high quality, fallback to hqdefault
        return URL(string: "https://img.youtube.com/vi/\(videoID)/mqdefault.jpg")
    }

    var body: some View {
        Button(action: {
            showVideo = true
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }) {
            HStack(spacing: 14) {
                // Video Thumbnail with Play Overlay
                ZStack {
                    if let thumbnailURL = thumbnailURL {
                        // YouTube thumbnail
                        AsyncImage(url: thumbnailURL) { phase in
                            switch phase {
                            case .empty:
                                thumbnailPlaceholder
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 90, height: 70)
                                    .clipped()
                            case .failure:
                                thumbnailPlaceholder
                            @unknown default:
                                thumbnailPlaceholder
                            }
                        }
                        .frame(width: 90, height: 70)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    } else {
                        thumbnailPlaceholder
                    }

                    // Play button overlay
                    Circle()
                        .fill(.black.opacity(0.4))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "play.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .offset(x: 1)
                        )
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

                    // Has video indicator
                    if youtubeVideoID != nil {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Image(systemName: "video.fill")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(4)
                                    .background(Color.red)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                        }
                        .frame(width: 90, height: 70)
                        .padding(4)
                    }
                }
                .frame(width: 90, height: 70)

                // Exercise Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(exercise.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Color.theme.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 6) {
                        // Sub-category pill
                        if !exercise.sub_category.isEmpty {
                            Text(exercise.sub_category)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.theme.primary.opacity(0.8))
                                )
                        }

                        Spacer()
                    }
                }

                // Favorite Button
                Button(action: {
                    onFavoriteTap()
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isFavorite ? .red : Color.theme.textSecondary.opacity(0.6))
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(isFavorite ? Color.red.opacity(0.15) : Color.theme.background.opacity(0.5))
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.2), Color.white.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(.plain)
        .pressEvents(onPress: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                isPressed = true
            }
        }, onRelease: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                isPressed = false
            }
        })
        .fullScreenCover(isPresented: $showVideo) {
            KineExerciseVideoView(exercise: exercise)
        }
    }

    // Placeholder when no thumbnail — uses skeleton shimmer while loading
    private var thumbnailPlaceholder: some View {
        SkeletonView(height: 70, cornerRadius: 12)
            .frame(width: 90, height: 70)
            .overlay(
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.4))
            )
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
                
                TextField("kine.search_exercises".localizedString, text: $searchText)
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
                        Text("kine.favorites".localizedString)
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
                        Text("kine.exercises".localizedString)
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
                        
                        Text(category == .mobility ? "kine.mobility".localizedString : "kine.strengthening".localizedString)
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
    
    var tips: [(String, String, String)] {
        [
            ("figure.walk", "kine.stay_active".localizedString, "kine.light_movement".localizedString),
            ("drop.fill", "kine.hydrate".localizedString, "kine.drink_water".localizedString),
            ("bed.double.fill", "kine.rest_well".localizedString, "kine.quality_sleep".localizedString),
            ("fork.knife", "kine.eat_protein".localizedString, "kine.support_muscle".localizedString),
            ("figure.cooldown", "kine.stretch_daily".localizedString, "kine.maintain_flexibility".localizedString),
            ("heart.fill", "kine.listen_body".localizedString, "kine.rest_when_needed".localizedString)
        ]
    }
    
    var body: some View {
        NavigationStack {
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
            .navigationTitle("kine.recovery_tips".localized)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Recommended Exercises Story Row
struct RecommendedExercisesRow: View {
    let exercises: [KineExercise]
    let favorites: Set<Int>
    let onExerciseTap: (KineExercise) -> Void
    let onPlayAllTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("kine.recommended".localizedString)
                        .font(.headline.bold())
                        .foregroundColor(.white)

                    Text("kine.based_on_favorites".localizedString)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }

                Spacer()

                Button(action: onPlayAllTap) {
                    HStack(spacing: 4) {
                        Image(systemName: "play.fill")
                            .font(.caption.bold())
                        Text("kine.play_all".localizedString)
                            .font(.caption.bold())
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.theme.primary, Color.theme.accent],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
            }
            .padding(.horizontal, 16)

            // Stories ScrollView
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(exercises) { exercise in
                        ExerciseStoryBubble(
                            exercise: exercise,
                            isFavorite: favorites.contains(exercise.id),
                            onTap: { onExerciseTap(exercise) }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Exercise Story Bubble with Video Thumbnail
struct ExerciseStoryBubble: View {
    let exercise: KineExercise
    let isFavorite: Bool
    let onTap: () -> Void

    @State private var isPressed = false

    // Extract YouTube video ID for thumbnail
    private var youtubeVideoID: String? {
        guard let urlString = exercise.video_url, !urlString.isEmpty else { return nil }

        if urlString.contains("youtu.be/") {
            if let url = URL(string: urlString) { return url.lastPathComponent }
        }
        if urlString.contains("/shorts/") {
            if let url = URL(string: urlString) { return url.lastPathComponent }
        }
        if let url = URL(string: urlString),
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems,
           let videoID = queryItems.first(where: { $0.name == "v" })?.value {
            return videoID
        }
        if urlString.contains("/embed/") {
            if let url = URL(string: urlString) { return url.lastPathComponent }
        }
        return nil
    }

    private var thumbnailURL: URL? {
        guard let videoID = youtubeVideoID else { return nil }
        return URL(string: "https://img.youtube.com/vi/\(videoID)/mqdefault.jpg")
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Circle with gradient border and thumbnail
                ZStack {
                    // Gradient ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: isFavorite
                                    ? [.yellow, .orange]
                                    : [Color.theme.primary, Color.theme.accent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 72, height: 72)

                    // Inner circle with thumbnail or icon
                    if let thumbnailURL = thumbnailURL {
                        AsyncImage(url: thumbnailURL) { phase in
                            switch phase {
                            case .empty:
                                placeholderCircle
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 64, height: 64)
                                    .clipShape(Circle())
                            case .failure:
                                placeholderCircle
                            @unknown default:
                                placeholderCircle
                            }
                        }
                        .frame(width: 64, height: 64)
                    } else {
                        placeholderCircle
                    }

                    // Play indicator
                    if youtubeVideoID != nil {
                        Circle()
                            .fill(.black.opacity(0.3))
                            .frame(width: 28, height: 28)
                            .overlay(
                                Image(systemName: "play.fill")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                    .offset(x: 1)
                            )
                    }

                    // Favorite indicator
                    if isFavorite {
                        Circle()
                            .fill(.red)
                            .frame(width: 18, height: 18)
                            .overlay(
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .offset(x: 24, y: -24)
                    }
                }

                // Exercise name (truncated)
                Text(exercise.name)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)
                    .frame(width: 72)
            }
            .scaleEffect(isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }

    private var placeholderCircle: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.theme.primary.opacity(0.3),
                        Color.theme.accent.opacity(0.2)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 64, height: 64)
            .overlay(
                Image(systemName: exerciseIcon)
                    .font(.title2.bold())
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
    }

    private var exerciseIcon: String {
        let name = exercise.name.lowercased()
        if name.contains("stretch") || name.contains("etirement") {
            return "figure.flexibility"
        } else if name.contains("squat") || name.contains("leg") {
            return "figure.strengthtraining.traditional"
        } else if name.contains("core") || name.contains("plank") || name.contains("gainage") {
            return "figure.core.training"
        } else if name.contains("arm") || name.contains("push") {
            return "figure.arms.open"
        } else {
            return "figure.cooldown"
        }
    }
}

// Make KineExercise work with fullScreenCover item binding
extension KineExercise {
    // Already conforms to Identifiable via id property
}
