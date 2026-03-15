//
//  ProfileViewModel.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 11/11/2025.
//

import Foundation
import Combine
import SwiftUI
import os // <-- 1. Import os.log

class ProfileViewModel: ObservableObject {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "DiPODDI", category: "ProfileViewModel")

    // For ReminderSettingsView
    @Published var reminderSettings: ReminderSettings?

    // For ProgressTrackingView (from API)
    @Published var progressLogs: [UserProgress] = []

    // For DashboardStatsView (from HealthKit)
    @Published var stepsToday: Int?
    @Published var caloriesToday: Int?
    @Published var latestWeight: Double?

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()
    private let healthKitManager = HealthKitManager.shared
    private let api = APIService.shared

    // Preview detection
    private var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    @MainActor
    init() {
        logger.info("👤 ProfileViewModel initialized (Preview: \(self.isPreview))")

        if isPreview {
            logger.info("⚠️ Running in preview mode - loading mock data")
            loadMockData()
        }
    }

    // MARK: - Mock Data for Preview
    @MainActor
    func loadMockData() {
        logger.info("📦 Loading mock profile data")

        self.reminderSettings = ReminderSettings(
            id: 1,
            breakfast_enabled: true,
            breakfast_time: "08:00",
            lunch_enabled: true,
            lunch_time: "12:00",
            dinner_enabled: true,
            dinner_time: "19:00",
            workout_enabled: true,
            workout_time: "07:00"
        )

        self.progressLogs = [
            UserProgress(id: 1, user_id: 1, date: "2025-01-15", weight: 75.0, waist: 80.0, chest: 95.0, hips: 90.0, mood: "good", notes: "Feeling great", workout_completed: nil),
            UserProgress(id: 2, user_id: 1, date: "2025-01-10", weight: 76.0, waist: 81.0, chest: 94.0, hips: 91.0, mood: "ok", notes: nil, workout_completed: nil)
        ]

        self.stepsToday = 8500
        self.caloriesToday = 350
        self.latestWeight = 75.0

        logger.info("✅ Loaded mock profile data")
    }
    
    func fetchAllData() {
        // Skip API calls in preview
        guard !isPreview else {
            logger.info("⚠️ Skipping fetchAllData() - running in preview mode")
            return
        }

        logger.info("📥 ProfileViewModel: Fetching all data...")
        fetchReminderSettings()
        fetchProgressLogs()
        requestHealthKitPermission() // This will trigger the HealthKit fetches
        logger.info("✅ ProfileViewModel: All data fetch requests initiated")
    }

    // MARK: - Async/Await API Methods
    @MainActor
    func fetchAllDataAsync() async {
        // Skip API calls in preview
        guard !isPreview else {
            logger.info("⚠️ Skipping fetchAllDataAsync() - running in preview mode")
            loadMockData()
            return
        }

        logger.info("📥 ProfileViewModel: Fetching all data (async)...")
        isLoading = true
        errorMessage = nil

        // Fetch in parallel
        async let progressTask: () = fetchProgressLogsAsync()
        async let remindersTask: () = fetchReminderSettingsAsync()

        await progressTask
        await remindersTask

        // Also fetch health data
        requestHealthKitPermission()

        isLoading = false
        logger.info("✅ ProfileViewModel: All async data fetch completed")
    }

    @MainActor
    func fetchProgressLogsAsync() async {
        guard !isPreview else { return }

        logger.info("📈 ProfileViewModel: Fetching progress logs (async)...")

        do {
            let logs: [UserProgress] = try await api.request(endpoint: "/api/user-progress", method: "GET")
            self.progressLogs = logs
            self.latestWeight = logs.first(where: { $0.weight != nil })?.weight

            logger.info("✅ ProfileViewModel: Loaded \(logs.count) progress logs")
            if let weight = self.latestWeight {
                logger.debug("   - Latest weight: \(weight) kg")
            }
        } catch {
            logger.error("❌ ProfileViewModel: Failed to fetch progress logs - \(error.localizedDescription)")
            self.errorMessage = "Failed to load progress: \(error.localizedDescription)"
        }
    }

    @MainActor
    func fetchReminderSettingsAsync() async {
        guard !isPreview else { return }

        logger.info("🔔 ProfileViewModel: Fetching reminder settings (async)...")

        do {
            let settings: ReminderSettings = try await api.request(endpoint: "/api/settings/reminders", method: "GET")
            self.reminderSettings = settings
            logger.info("✅ ProfileViewModel: Reminder settings loaded")
        } catch {
            logger.error("❌ ProfileViewModel: Failed to fetch reminder settings - \(error.localizedDescription)")
        }
    }
    
    // --- HealthKit ---
    
    func requestHealthKitPermission() {
        guard healthKitManager.isHealthDataAvailable else { return }
        
        healthKitManager.requestAuthorization { [weak self] (success, error) in
            if success {
                self?.logger.info("HealthKit authorized.")
                self?.fetchHealthData()
            } else {
                self?.logger.warning("HealthKit authorization denied.")
            }
        }
    }
    
    func fetchHealthData() {
        logger.info("📊 ProfileViewModel: Fetching HealthKit data...")
        healthKitManager.fetchTodayHealthData { [weak self] (data: HealthData) in
            DispatchQueue.main.async {
                self?.stepsToday = data.steps
                self?.caloriesToday = data.activeCalories
                self?.logger.info("✅ ProfileViewModel: HealthKit data loaded")
                self?.logger.info("   - Steps: \(data.steps ?? 0)")
                self?.logger.info("   - Calories: \(data.activeCalories ?? 0)")
            }
        }
    }

    // --- Reminders ---
    
    func fetchReminderSettings() {
        logger.info("🔔 ProfileViewModel: Fetching reminder settings...")
        isLoading = true
        APIService.shared.request(endpoint: "/api/settings/reminders", method: "GET")
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.logger.error("❌ ProfileViewModel: Failed to fetch reminder settings - \(error.localizedDescription)")
                } else {
                    self?.logger.info("✅ ProfileViewModel: Reminder settings loaded")
                }
            }, receiveValue: { [weak self] (settings: ReminderSettings) in
                self?.reminderSettings = settings
            })
            .store(in: &cancellables)
    }
    
    func saveReminderSettings(settings: ReminderSettings) {
        let previousSettings = self.reminderSettings
        self.reminderSettings = settings // Optimistic update
        isLoading = true

        APIService.shared.request(endpoint: "/api/settings/reminders", method: "PUT", body: settings)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.reminderSettings = previousSettings // Revert on failure
                    self?.errorMessage = error.localizedDescription
                }
            },
                  receiveValue: { (response: APIResponseMessage) in
                #if DEBUG
                print("Reminders saved!")
                #endif
            })
            .store(in: &cancellables)
    }
    
    // --- Progress Logging ---
    
    func fetchProgressLogs() {
        logger.info("📈 ProfileViewModel: Fetching progress logs...")
        APIService.shared.request(endpoint: "/api/user-progress", method: "GET")
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = "Failed to load progress: \(error.localizedDescription)"
                    self?.logger.error("❌ ProfileViewModel: Failed to fetch progress logs - \(error.localizedDescription)")
                } else {
                    self?.logger.info("✅ ProfileViewModel: Progress logs loaded successfully")
                }
            }, receiveValue: { [weak self] (logs: [UserProgress]) in
                self?.progressLogs = logs
                // Update the dashboard stat with the latest weight
                self?.latestWeight = logs.first(where: { $0.weight != nil })?.weight
                
                self?.logger.info("📊 ProfileViewModel: Loaded \(logs.count) progress logs")
                if let weight = self?.latestWeight {
                    self?.logger.debug("   - Latest weight: \(weight) kg")
                }
            })
            .store(in: &cancellables)
    }
    
    func logProgress(date: Date, weight: String, waist: String, chest: String, hips: String, notes: String, mood: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        
        let weightDouble = Double(weight)
        let waistDouble = Double(waist)
        
        let body: [String: AnyEncodable] = [
            "date": AnyEncodable(formatter.string(from: date)),
            "weight": AnyEncodable(weightDouble),
            "waist": AnyEncodable(waistDouble),
            "chest": AnyEncodable(Double(chest)),
            "hips": AnyEncodable(Double(hips)),
            "mood": AnyEncodable(mood.isEmpty ? nil : mood),
            "notes": AnyEncodable(notes.isEmpty ? nil : notes)
        ]
        
        APIService.shared.request(endpoint: "/api/user-progress", method: "POST", body: body)
            .sink(receiveCompletion: { completionResult in
                self.isLoading = false
                if case .failure(let error) = completionResult {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                }
            }, receiveValue: { (newLog: UserProgress) in
                #if DEBUG
                print("Progress logged successfully!")
                #endif
                self.progressLogs.insert(newLog, at: 0)
                self.latestWeight = newLog.weight ?? self.latestWeight
                
                // --- Save to HealthKit ---
                if let weight = weightDouble {
                    self.healthKitManager.saveWeightMeasurement(weight, date: date) { _,_ in }
                }
                if let waist = waistDouble {
                    self.healthKitManager.saveWaistMeasurement(waist, date: date) { _,_ in }
                }
                
                completion(true)
            })
            .store(in: &cancellables)
    }
}

// Helper for sending mixed-type dictionaries
struct AnyEncodable: Encodable {
    private let encodeClosure: (Encoder) throws -> Void
    public init<T: Encodable>(_ value: T?) {
        self.encodeClosure = { encoder in
            var container = encoder.singleValueContainer()
            if let value = value {
                try container.encode(value)
            } else {
                try container.encodeNil()
            }
        }
    }
    public func encode(to encoder: Encoder) throws {
        try encodeClosure(encoder)
    }
}
