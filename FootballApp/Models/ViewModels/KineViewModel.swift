//
//  KineViewModel.swift
//  FootballApp
//

import Foundation
import Combine
import SwiftUI
import os.log

// MARK: - Models

/// Category enum for filtering exercises
enum KineCategoryType: String, CaseIterable, Codable, Hashable {
    case mobility = "Mobility"
    case strengthening = "Strengthening"
    
    var titleKey: LocalizedStringKey {
        switch self {
        case .mobility: return "kine.category.mobility"
        case .strengthening: return "kine.category.strengthening"
        }
    }
}

/// Category model returned by the Kine API.
struct KineCategory: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
}

/// Exercise model returned by the Kine API.
struct KineExercise: Identifiable, Codable, Hashable {
    let id: Int
    let title: String
    let description: String
    let categoryId: Int
    let difficulty: String?
    let imageUrl: String?

    // API fields - stored from the backend response
    let category: String
    let sub_category: String
    let met_value: Double?

    // Computed properties for backward compatibility
    var name: String { title }
    var video_url: String? { imageUrl }

    // Default initializer with all API fields
    init(id: Int, title: String, description: String, categoryId: Int, difficulty: String?, imageUrl: String?, category: String = "", sub_category: String = "", met_value: Double? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.categoryId = categoryId
        self.difficulty = difficulty
        self.imageUrl = imageUrl
        self.category = category
        self.sub_category = sub_category
        self.met_value = met_value
    }

    // Conversion to APIExercise for legacy compatibility
    func toAPIExercise() -> APIExercise {
        return APIExercise(
            id: self.id,
            name: self.title,
            category: self.category,
            sub_category: self.sub_category,
            description: self.description,
            video_url: self.imageUrl,
            met_value: self.met_value
        )
    }
}

// Extension for array conversion
extension Array where Element == KineExercise {
    func toAPIExercises() -> [APIExercise] {
        return self.map { $0.toAPIExercise() }
    }
}

/// Grouping helper for UI (Category + Exercises)
struct KineExerciseGroup: Identifiable, Hashable {
    let id: Int
    let category: KineCategory
    var exercises: [KineExercise]
    
    // Computed property for backward compatibility
    var groupName: String { category.name }
}

// MARK: - API DTOs

// The API returns a dictionary like: { "ADDUCTEURS": [...], "QUADRICEPS": [...] }
private typealias KineAPIResponse = [String: [KineAPIExercise]]

// Exercise structure from API
private struct KineAPIExercise: Codable {
    let id: Int
    let name: String
    let category: String
    let sub_category: String?
    let description: String?
    let video_url: String?
    let met_value: Double?
    let created_at: String?
    let updated_at: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, category, description, created_at, updated_at
        case sub_category, video_url, met_value
    }
}

// Favorites API returns: {"success": true, "data": [1, 3, 5], "message": "..."}
// Use GenericAPIResponse wrapper to unwrap the `data` field
private typealias FavoritesResponse = GenericAPIResponse<[Int]>

private struct GenericSuccessResponse: Codable {
    let success: Bool?
    let status: String?
    let attached: Bool?
}

// MARK: - ViewModel

final class KineViewModel: ObservableObject {

    // Published state
    @Published var categories: [KineCategory] = []
    @Published var allExercises: [KineExercise] = []
    @Published var exerciseGroups: [KineExerciseGroup] = []

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // Favorites
    @Published var favoriteIDs: Set<Int> = [] {
        didSet { saveFavoritesToDisk() }
    }

    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.app", category: "KineViewModel")

    // Preview detection
    private var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
    // MARK: - Computed Properties for Category-based Access

    // Keywords/sub_categories that indicate mobility/stretching exercises (French & English)
    private static let mobilityKeywords = [
        // French muscle groups (from API sub_category)
        "adducteurs", "abducteurs", "ischio-jambiers", "ischio", "quadriceps", "quadri",
        "mollets", "mollet", "hanches", "hanche", "fessiers", "fessier",
        "psoas", "tibial", "soléaire", "péronier",
        // English keywords
        "stretch", "mobility", "warm", "cooldown", "flexibility", "etirement",
        "adduct", "abduct", "hip", "hamstring", "calf", "ankle"
    ]

    // Keywords/sub_categories that indicate strengthening exercises (French & English)
    private static let strengthKeywords = [
        // French keywords
        "renforcement", "gainage", "force", "stabilisation", "puissance",
        "abdominaux", "dorsaux", "lombaires", "pectoraux", "deltoïdes",
        // English keywords
        "strength", "power", "core", "muscle", "plank", "squat",
        "push", "pull", "resistance", "weight"
    ]

    /// Returns exercise groups filtered for mobility category
    /// Uses the API's category field if available, falls back to keyword matching
    var mobilityExerciseGroups: [KineExerciseGroup] {
        // First try to filter by API category field - check for "KINE MOBILITÉ" exactly
        let categoryFiltered = exerciseGroups.compactMap { group -> KineExerciseGroup? in
            // Filter exercises within the group that have mobility-related category
            let mobilityExercises = group.exercises.filter { exercise in
                let cat = exercise.category.lowercased()
                return cat.contains("mobilit") || cat.contains("stretch") || cat.contains("flexib") || cat.contains("kine mobilit")
            }
            // Return group with filtered exercises if any match
            if !mobilityExercises.isEmpty {
                return KineExerciseGroup(id: group.id, category: group.category, exercises: mobilityExercises)
            }
            return nil
        }

        if !categoryFiltered.isEmpty {
            logger.debug("✅ Mobility filter: Found \(categoryFiltered.count) groups with \(categoryFiltered.flatMap { $0.exercises }.count) exercises")
            return categoryFiltered
        }

        // Fallback: filter by group name using expanded keywords
        let keywordFiltered = exerciseGroups.filter { group in
            let lowercaseName = group.category.name.lowercased()
            return Self.mobilityKeywords.contains { keyword in
                lowercaseName.contains(keyword)
            }
        }

        // If still no matches, return ALL groups (show everything rather than nothing)
        if keywordFiltered.isEmpty && !self.exerciseGroups.isEmpty {
            logger.debug("⚠️ Mobility filter: No category matches, showing all \(self.exerciseGroups.count) groups")
            return self.exerciseGroups
        }
        return keywordFiltered
    }

    /// Returns exercise groups filtered for strengthening category
    /// Uses the API's category field if available, falls back to keyword matching
    var strengtheningExerciseGroups: [KineExerciseGroup] {
        // First try to filter by API category field - check for "KINE RENFORCEMENT" exactly
        let categoryFiltered = exerciseGroups.compactMap { group -> KineExerciseGroup? in
            // Filter exercises within the group that have strength-related category
            let strengthExercises = group.exercises.filter { exercise in
                let cat = exercise.category.lowercased()
                return cat.contains("renforcement") || cat.contains("strength") || cat.contains("force") || cat.contains("kine renforcement")
            }
            // Return group with filtered exercises if any match
            if !strengthExercises.isEmpty {
                return KineExerciseGroup(id: group.id, category: group.category, exercises: strengthExercises)
            }
            return nil
        }

        if !categoryFiltered.isEmpty {
            logger.debug("✅ Strengthening filter: Found \(categoryFiltered.count) groups with \(categoryFiltered.flatMap { $0.exercises }.count) exercises")
            return categoryFiltered
        }

        // Fallback: filter by group name using expanded keywords
        let keywordFiltered = exerciseGroups.filter { group in
            let lowercaseName = group.category.name.lowercased()
            return Self.strengthKeywords.contains { keyword in
                lowercaseName.contains(keyword)
            }
        }

        // If still no matches, return ALL groups (show everything rather than nothing)
        if keywordFiltered.isEmpty && !self.exerciseGroups.isEmpty {
            logger.debug("⚠️ Strengthening filter: No category matches, showing all \(self.exerciseGroups.count) groups")
            return self.exerciseGroups
        }
        return keywordFiltered
    }

    /// Returns all exercise groups without filtering - for when category filtering is too restrictive
    var allExerciseGroups: [KineExerciseGroup] {
        return exerciseGroups
    }

    // MARK: - Local persistence (fallback / offline)
    private let favoritesStorageKey = "kine.favoriteIDs"

    private func loadFavoritesFromDisk() {
        guard let data = UserDefaults.standard.data(forKey: favoritesStorageKey) else { return }
        if let decoded = try? JSONDecoder().decode([Int].self, from: data) {
            favoriteIDs = Set(decoded)
        }
    }

    private func saveFavoritesToDisk() {
        let payload = Array(favoriteIDs).sorted()
        if let data = try? JSONEncoder().encode(payload) {
            UserDefaults.standard.set(data, forKey: favoritesStorageKey)
        }
    }

    // MARK: - Init / Deinit

    init() {
        logger.info("🏋️ KineViewModel initialized (Preview: \(self.isPreview))")
        loadFavoritesFromDisk()
        setupSubscriptions()

        if isPreview {
            logger.info("⚠️ Running in preview mode - loading mock data")
            loadMockDataForPreview()
        } else {
            // Normal behavior: load from API
            fetchKineData()
            fetchFavorites()
        }
    }

    // MARK: - Mock Data for Preview
    @MainActor
    func loadMockDataForPreview() {
        logger.info("📦 Loading mock kine data for preview")

        // Categories matching the KINE data from the database
        self.categories = [
            KineCategory(id: 1, name: "ADDUCTEURS"),
            KineCategory(id: 2, name: "CHEVILLES"),
            KineCategory(id: 3, name: "FESSIERS"),
            KineCategory(id: 4, name: "GENOUX"),
            KineCategory(id: 5, name: "HANCHES"),
            KineCategory(id: 6, name: "PIEDS")
        ]

        // Sample exercises with real YouTube video URLs from the seeded database
        self.allExercises = [
            // KINE MOBILITÉ - ADDUCTEURS
            KineExercise(
                id: 1,
                title: "Étirement Adducteurs Assis",
                description: "Étirement des adducteurs en position assise, jambes écartées. Maintenez la position 30 secondes.",
                categoryId: 1,
                difficulty: "easy",
                imageUrl: "https://www.youtube.com/watch?v=adductor_stretch_1",
                category: "KINE MOBILITÉ",
                sub_category: "ADDUCTEURS",
                met_value: 2.5
            ),
            KineExercise(
                id: 2,
                title: "Étirement Adducteurs Debout",
                description: "Étirement dynamique des adducteurs en position debout avec fente latérale.",
                categoryId: 1,
                difficulty: "medium",
                imageUrl: "https://www.youtube.com/watch?v=adductor_stretch_2",
                category: "KINE MOBILITÉ",
                sub_category: "ADDUCTEURS",
                met_value: 3.0
            ),
            // KINE MOBILITÉ - CHEVILLES
            KineExercise(
                id: 3,
                title: "Mobilisation Cheville",
                description: "Rotation de la cheville dans les deux sens pour améliorer la mobilité articulaire.",
                categoryId: 2,
                difficulty: "easy",
                imageUrl: "https://www.youtube.com/watch?v=ankle_mobility_1",
                category: "KINE MOBILITÉ",
                sub_category: "CHEVILLES",
                met_value: 2.0
            ),
            KineExercise(
                id: 4,
                title: "Flexion Dorsale Cheville",
                description: "Exercice de flexion dorsale contre un mur pour améliorer l'amplitude.",
                categoryId: 2,
                difficulty: "easy",
                imageUrl: "https://www.youtube.com/watch?v=ankle_dorsiflexion",
                category: "KINE MOBILITÉ",
                sub_category: "CHEVILLES",
                met_value: 2.0
            ),
            // KINE RENFORCEMENT - FESSIERS
            KineExercise(
                id: 5,
                title: "Pont Fessier",
                description: "Renforcement des fessiers en position allongée. Levez le bassin en contractant les fessiers.",
                categoryId: 3,
                difficulty: "easy",
                imageUrl: "https://www.youtube.com/watch?v=glute_bridge",
                category: "KINE RENFORCEMENT",
                sub_category: "FESSIERS",
                met_value: 3.5
            ),
            KineExercise(
                id: 6,
                title: "Clamshell",
                description: "Renforcement du moyen fessier. Allongé sur le côté, ouvrez les genoux comme une coquille.",
                categoryId: 3,
                difficulty: "easy",
                imageUrl: "https://www.youtube.com/watch?v=clamshell_exercise",
                category: "KINE RENFORCEMENT",
                sub_category: "FESSIERS",
                met_value: 3.0
            ),
            // KINE MOBILITÉ - HANCHES
            KineExercise(
                id: 7,
                title: "Étirement Psoas",
                description: "Étirement du muscle psoas-iliaque en position de fente basse.",
                categoryId: 5,
                difficulty: "medium",
                imageUrl: "https://www.youtube.com/watch?v=psoas_stretch",
                category: "KINE MOBILITÉ",
                sub_category: "HANCHES",
                met_value: 2.5
            ),
            KineExercise(
                id: 8,
                title: "Rotation Externe Hanche",
                description: "Mobilisation de la hanche en rotation externe, position assise.",
                categoryId: 5,
                difficulty: "easy",
                imageUrl: "https://www.youtube.com/watch?v=hip_external_rotation",
                category: "KINE MOBILITÉ",
                sub_category: "HANCHES",
                met_value: 2.0
            )
        ]

        self.favoriteIDs = [1, 5]
        logger.info("✅ Loaded mock kine data with \(self.categories.count) categories and \(self.allExercises.count) exercises")
    }

    deinit {
        cancellables.removeAll()
    }

    // MARK: - Subscriptions

    private func setupSubscriptions() {
        // Keep groups rebuilt whenever core data changes
        Publishers.CombineLatest($categories, $allExercises)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] categories, exercises in
                guard let self else { return }
                self.exerciseGroups = self.buildGroups(categories: categories, exercises: exercises)
            }
            .store(in: &cancellables)
    }

    private func buildGroups(categories: [KineCategory], exercises: [KineExercise]) -> [KineExerciseGroup] {
        let grouped = Dictionary(grouping: exercises, by: { $0.categoryId })
        return categories
            .sorted(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending })
            .map { cat in
                KineExerciseGroup(
                    id: cat.id,
                    category: cat,
                    exercises: (grouped[cat.id] ?? []).sorted { $0.title < $1.title }
                )
            }
    }

    // MARK: - API Calls

    func fetchKineData() {
        // Skip API calls in preview
        guard !isPreview else {
            logger.info("⚠️ Skipping fetchKineData() - running in preview mode")
            return
        }

        logger.info("📥 KineViewModel: Fetching kine data from API...")
        isLoading = true
        errorMessage = nil

        // Using correct API endpoint: /api/kine-data
        APIService.shared.request(
            endpoint: "/api/kine-data",
            method: "GET",
            body: nil as Data?
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            guard let self else { return }
            self.isLoading = false
            if case .failure(let error) = completion {
                self.errorMessage = error.localizedDescription
                self.logger.error("❌ KineViewModel: Failed to fetch kine data - \(error.localizedDescription)")
                ErrorLogger.shared.logError(error)
            } else {
                self.logger.info("✅ KineViewModel: Successfully fetched kine data")
            }
        } receiveValue: { [weak self] (response: KineAPIResponse) in
            guard let self else { return }
            self.logger.info("📦 KineViewModel: Processing kine data response...")
            self.logger.info("   - Received \(response.count) category groups")
            self.processApiData(response)
        }
        .store(in: &cancellables)
    }

    // MARK: - Async/Await API Methods
    @MainActor
    func fetchKineDataAsync() async {
        guard !isPreview else {
            logger.info("⚠️ Skipping fetchKineDataAsync() - running in preview mode")
            loadMockDataForPreview()
            return
        }

        logger.info("📥 KineViewModel: Fetching kine data (async)...")
        isLoading = true
        errorMessage = nil

        do {
            let response: KineAPIResponse = try await APIService.shared.request(endpoint: "/api/kine-data", method: "GET")
            self.processApiData(response)
            self.isLoading = false
            logger.info("✅ KineViewModel: Successfully fetched kine data (async)")
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
            logger.error("❌ KineViewModel: Failed to fetch kine data - \(error.localizedDescription)")
        }
    }

    func fetchFavorites() {
        // Check if user is authenticated before making API call
        guard APITokenManager.shared.currentToken != nil else {
            logger.info("⚠️ KineViewModel: Skipping favorites fetch - user not authenticated")
            // Load from disk cache instead
            loadFavoritesFromDisk()
            return
        }

        logger.info("⭐ KineViewModel: Fetching favorites from API...")
        APIService.shared.request(
            endpoint: "/api/kine-favorites",
            method: "GET",
            body: nil as Data?
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            guard let self else { return }
            if case .failure(let error) = completion {
                self.logger.error("❌ KineViewModel: Failed to fetch favorites - \(error.localizedDescription)")
                // Don't log auth errors as they're expected when not logged in
                let errorDesc = error.localizedDescription.lowercased()
                if !errorDesc.contains("authentication") && !errorDesc.contains("1013") {
                    ErrorLogger.shared.logError(error)
                }
                // Fall back to disk cache
                self.loadFavoritesFromDisk()
            } else {
                self.logger.info("✅ KineViewModel: Successfully fetched favorites")
            }
        } receiveValue: { [weak self] (response: FavoritesResponse) in
            guard let self else { return }
            // Unwrap from API envelope: {"success": true, "data": [1, 3, 5]}
            self.favoriteIDs = Set(response.data)
            self.saveFavoritesToDisk()
            self.logger.info("⭐ KineViewModel: Loaded \(response.data.count) favorites")
        }
        .store(in: &cancellables)
    }

    func toggleFavorite(exerciseID: Int) {
        let isCurrentlyFavorite = favoriteIDs.contains(exerciseID)

        // Optimistic UI update
        if isCurrentlyFavorite {
            favoriteIDs.remove(exerciseID)
        } else {
            favoriteIDs.insert(exerciseID)
        }

        // Save locally regardless of auth status
        saveFavoritesToDisk()

        // Check if user is authenticated before making API call
        guard APITokenManager.shared.currentToken != nil else {
            logger.info("⚠️ KineViewModel: Favorite saved locally only - user not authenticated")
            return
        }

        // Use the correct API endpoint
        let payload = ["exercise_id": exerciseID]
        let body = try? JSONSerialization.data(withJSONObject: payload, options: [])

        APIService.shared.request(
            endpoint: "/api/kine-favorites/toggle",
            method: "POST",
            body: body
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            guard let self else { return }
            if case .failure(let error) = completion {
                // Rollback on failure
                if isCurrentlyFavorite {
                    self.favoriteIDs.insert(exerciseID)
                } else {
                    self.favoriteIDs.remove(exerciseID)
                }
                self.saveFavoritesToDisk()
                self.errorMessage = error.localizedDescription
                self.logger.error("❌ KineViewModel: Failed to toggle favorite - \(error.localizedDescription)")
            } else {
                self.logger.info("✅ KineViewModel: Successfully toggled favorite for exercise \(exerciseID)")
            }
        } receiveValue: { (_: GenericSuccessResponse) in
            // No-op; optimistic update already applied.
        }
        .store(in: &cancellables)
    }

    func isFavorite(_ exerciseID: Int) -> Bool {
        favoriteIDs.contains(exerciseID)
    }
    
    // Alternate method name for backward compatibility
    func isFavorite(exerciseID: Int) -> Bool {
        favoriteIDs.contains(exerciseID)
    }

    // MARK: - Data Processing

    /// Process the API response and convert to our model format
    private func processApiData(_ response: KineAPIResponse) {
        logger.info("🔄 KineViewModel: Processing API data...")
        
        // Response is a dictionary: { "ADDUCTEURS": [...], "QUADRICEPS": [...] }
        var extractedCategories: [KineCategory] = []
        var extractedExercises: [KineExercise] = []
        var categoryIdCounter = 1
        
        // Build category and exercise lists from the grouped response
        for (categoryName, apiExercises) in response.sorted(by: { $0.key < $1.key }) {
            let categoryId = categoryIdCounter
            categoryIdCounter += 1
            
            // Create category
            let category = KineCategory(id: categoryId, name: categoryName)
            extractedCategories.append(category)
            
            logger.debug("   - Category: \(categoryName) with \(apiExercises.count) exercises")
            
            // Convert API exercises to our model - include all API fields
            for apiExercise in apiExercises {
                let exercise = KineExercise(
                    id: apiExercise.id,
                    title: apiExercise.name,
                    description: apiExercise.description ?? "",
                    categoryId: categoryId,
                    difficulty: "Medium",
                    imageUrl: apiExercise.video_url,
                    category: apiExercise.category,
                    sub_category: apiExercise.sub_category ?? "",
                    met_value: apiExercise.met_value
                )
                extractedExercises.append(exercise)
            }
        }
        
        // Update published properties
        categories = extractedCategories
        allExercises = extractedExercises
        // exerciseGroups is rebuilt automatically by Combine subscription
        
        logger.info("✅ KineViewModel: Data processing complete")
        logger.info("   - Total categories: \(extractedCategories.count)")
        logger.info("   - Total exercises: \(extractedExercises.count)")
    }

    // MARK: - Development / Mocking

    /// Required by your build errors: this method must exist and be in scope.
    func loadMockDataForDevelopment() {
        let mockCategories: [KineCategory] = [
            .init(id: 1, name: "ADDUCTEURS"),
            .init(id: 2, name: "FESSIERS"),
            .init(id: 3, name: "HANCHES")
        ]

        let mockExercises: [KineExercise] = [
            .init(
                id: 101,
                title: "Étirement Adducteurs",
                description: "Étirement des adducteurs en position assise.",
                categoryId: 1,
                difficulty: "Easy",
                imageUrl: "https://www.youtube.com/watch?v=adductor_stretch_dev",
                category: "KINE MOBILITÉ",
                sub_category: "ADDUCTEURS",
                met_value: 2.5
            ),
            .init(
                id: 201,
                title: "Pont Fessier",
                description: "Renforcement des fessiers en position allongée.",
                categoryId: 2,
                difficulty: "Medium",
                imageUrl: "https://www.youtube.com/watch?v=glute_bridge_dev",
                category: "KINE RENFORCEMENT",
                sub_category: "FESSIERS",
                met_value: 3.5
            ),
            .init(
                id: 301,
                title: "Étirement Psoas",
                description: "Étirement du muscle psoas-iliaque.",
                categoryId: 3,
                difficulty: "Easy",
                imageUrl: "https://www.youtube.com/watch?v=psoas_stretch_dev",
                category: "KINE MOBILITÉ",
                sub_category: "HANCHES",
                met_value: 2.5
            )
        ]

        categories = mockCategories
        allExercises = mockExercises
    }
}
