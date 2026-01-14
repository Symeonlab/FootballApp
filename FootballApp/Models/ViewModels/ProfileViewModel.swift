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
    // --- 2. ADD THIS LINE ---
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Dipodi", category: "ProfileViewModel")
    // --- END OF ADDITION ---

    // For ReminderSettingsView
    @Published var reminderSettings: ReminderSettings?
    
    // For ProgressTrackingView (from API)
    @Published var progressLogs: [UserProgress] = []
    
    // For DashboardStatsView (from HealthKit)
    @Published var stepsToday: Int?
    @Published var caloriesToday: Int?
    @Published var latestWeight: Double?
    
    // For MeasurementLogView - these should NOT be @State in a ViewModel
    // They will be managed in the View itself
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let healthKitManager = HealthKitManager.shared

    init() {
        // Fetch all data when the view is created
        fetchAllData()
    }
    
    func fetchAllData() {
        logger.info("📥 ProfileViewModel: Fetching all data...")
        fetchReminderSettings()
        fetchProgressLogs()
        requestHealthKitPermission() // This will trigger the HealthKit fetches
        logger.info("✅ ProfileViewModel: All data fetch requests initiated")
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
        self.reminderSettings = settings // Update local state
        isLoading = true
        
        APIService.shared.request(endpoint: "/api/settings/reminders", method: "PUT", body: settings)
            .sink(receiveCompletion: { _ in self.isLoading = false },
                  receiveValue: { (response: APIResponseMessage) in
                print("Reminders saved!")
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
                print("Progress logged successfully!")
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
