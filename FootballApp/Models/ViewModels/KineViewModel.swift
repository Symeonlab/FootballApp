//
//  KineViewModel.swift
//  FootballApp
//

import Foundation
import Combine
import SwiftUI

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
    
    // Computed properties for backward compatibility
    var name: String { title }
    var category: String { "" }
    var sub_category: String { "" }
    var video_url: String? { imageUrl }
    var met_value: Double? { nil }
    
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

private struct KineAPIResponse: Codable {
    let categories: [KineCategory]
    let exercises: [KineExercise]
}

private struct FavoritesResponse: Codable {
    struct FavoriteItem: Codable {
        let exerciseId: Int
    }
    let data: [FavoriteItem]
}

private struct GenericSuccessResponse: Codable {
    let success: Bool?
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
    
    // MARK: - Computed Properties for Category-based Access
    
    /// Returns exercise groups filtered for mobility category
    var mobilityExerciseGroups: [KineExerciseGroup] {
        exerciseGroups.filter { group in
            group.category.name.localizedCaseInsensitiveCompare("Mobility") == .orderedSame ||
            group.category.name.localizedCaseInsensitiveCompare("Stretching") == .orderedSame ||
            group.category.name.localizedCaseInsensitiveCompare("Warm-up") == .orderedSame
        }
    }
    
    /// Returns exercise groups filtered for strengthening category
    var strengtheningExerciseGroups: [KineExerciseGroup] {
        exerciseGroups.filter { group in
            group.category.name.localizedCaseInsensitiveCompare("Strength") == .orderedSame ||
            group.category.name.localizedCaseInsensitiveCompare("Strengthening") == .orderedSame ||
            group.category.name.localizedCaseInsensitiveCompare("Power") == .orderedSame
        }
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
        loadFavoritesFromDisk()
        setupSubscriptions()

        #if DEBUG
        // If you want mocked data while building UI without backend, enable this:
        // loadMockDataForDevelopment()
        #endif

        // Normal behavior: load from API
        fetchKineData()
        fetchFavorites()
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
        isLoading = true
        errorMessage = nil

        // Adjust endpoint paths to your backend routes if needed.
        APIService.shared.request(
            endpoint: "/kine/data",
            method: "GET",
            body: nil as Data?
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            guard let self else { return }
            self.isLoading = false
            if case .failure(let error) = completion {
                self.errorMessage = error.localizedDescription
                ErrorLogger.shared.logError(error)
            }
        } receiveValue: { [weak self] (response: KineAPIResponse) in
            guard let self else { return }
            self.processApiData(response)
        }
        .store(in: &cancellables)
    }

    func fetchFavorites() {
        APIService.shared.request(
            endpoint: "/kine/favorites",
            method: "GET",
            body: nil as Data?
        )
        .receive(on: DispatchQueue.main)
        .sink { completion in
            if case .failure(let error) = completion {
                ErrorLogger.shared.logError(error)
            }
        } receiveValue: { [weak self] (response: FavoritesResponse) in
            guard let self else { return }
            self.favoriteIDs = Set(response.data.map { $0.exerciseId })
            self.saveFavoritesToDisk()
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

        let endpoint = isCurrentlyFavorite ? "/kine/favorites/remove" : "/kine/favorites/add"
        let payload = ["exerciseId": exerciseID]
        let body = try? JSONSerialization.data(withJSONObject: payload, options: [])

        APIService.shared.request(
            endpoint: endpoint,
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
                self.errorMessage = error.localizedDescription
                ErrorLogger.shared.logError(error)
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

    /// Required by your build errors: this method must exist and be in scope.
    private func processApiData(_ response: KineAPIResponse) {
        categories = response.categories
        allExercises = response.exercises
        // exerciseGroups is rebuilt by Combine subscription
    }

    // MARK: - Development / Mocking

    /// Required by your build errors: this method must exist and be in scope.
    func loadMockDataForDevelopment() {
        let mockCategories: [KineCategory] = [
            .init(id: 1, name: "Warm-up"),
            .init(id: 2, name: "Strength"),
            .init(id: 3, name: "Stretching")
        ]

        let mockExercises: [KineExercise] = [
            .init(id: 101, title: "Jumping Jacks", description: "Light cardio warm-up.", categoryId: 1, difficulty: "Easy", imageUrl: nil),
            .init(id: 201, title: "Push-ups", description: "Upper body strength.", categoryId: 2, difficulty: "Medium", imageUrl: nil),
            .init(id: 301, title: "Hamstring Stretch", description: "Post-workout stretch.", categoryId: 3, difficulty: "Easy", imageUrl: nil)
        ]

        categories = mockCategories
        allExercises = mockExercises
    }
}
