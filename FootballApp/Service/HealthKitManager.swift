//
//  HealthKitManager.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 14/11/2025.
//

import Foundation
import HealthKit
import os

final class HealthKitManager {
    static let shared = HealthKitManager()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "DiPODDI", category: "HealthKitManager")

    private let healthStore = HKHealthStore()

    // Define the data types we want to read and write
    private var readTypes: Set<HKObjectType> {
        // Use compactMap to safely unwrap optional quantity types
        let quantityIdentifiers: [HKQuantityTypeIdentifier] = [
            .stepCount,
            .activeEnergyBurned,
            .basalEnergyBurned,        // Resting calories
            .bodyMass,                  // Weight
            .height,
            .waistCircumference,
            .vo2Max,
            .distanceWalkingRunning,
            .distanceCycling,
            .appleExerciseTime,
            .appleStandTime,            // Stand hours data
            .heartRate,
            .restingHeartRate,
            .heartRateVariabilitySDNN,  // HRV
            .oxygenSaturation,          // Blood oxygen
            .respiratoryRate,
            .flightsClimbed,
            .walkingSpeed,
            .walkingStepLength,
            .walkingDoubleSupportPercentage
        ]

        var types: Set<HKObjectType> = Set(quantityIdentifiers.compactMap {
            HKObjectType.quantityType(forIdentifier: $0)
        })

        // Add activity summary type for Apple Watch rings
        let activitySummaryType: HKObjectType = HKObjectType.activitySummaryType()
        types.insert(activitySummaryType)

        return types
    }

    private var writeTypes: Set<HKSampleType> {
         return Set([
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .waistCircumference)!,
        ])
    }

    private init() {}

    var isHealthDataAvailable: Bool {
        return HKHealthStore.isHealthDataAvailable()
    }

    // 1. Request Authorization from the User
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard isHealthDataAvailable else {
            logger.info("HealthKit not available on this device/simulator")
            completion(false, nil)
            return
        }
        
        #if targetEnvironment(simulator)
        // On simulator, HealthKit may not work properly - mock success
        logger.info("⚠️ Running on Simulator - HealthKit may not be fully functional")
        DispatchQueue.main.async {
            completion(true, nil)
        }
        #else
        healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { (success, error) in
            self.logger.info("HealthKit Auth Success: \(success), Error: \(error?.localizedDescription ?? "None")")
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
        #endif
    }
    
    // 2. Read Today's Step Count
    func readTodaySteps(completion: @escaping (Double?, Error?) -> Void) {
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            completion(nil, nil); return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            let value = result?.sumQuantity()?.doubleValue(for: HKUnit.count())
            DispatchQueue.main.async {
                completion(value, error)
            }
        }
        healthStore.execute(query)
    }

    // 3. Read Today's Active Calories
    func readTodayActiveEnergy(completion: @escaping (Double?, Error?) -> Void) {
        guard let energyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(nil, nil); return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: energyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            let value = result?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie())
            DispatchQueue.main.async {
                completion(value, error)
            }
        }
        healthStore.execute(query)
    }
    
    // 4. Write a new Weight Measurement
    func saveWeightMeasurement(_ weight: Double, date: Date, completion: @escaping (Bool, Error?) -> Void) {
        guard let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass) else {
            completion(false, nil); return
        }
        
        let weightQuantity = HKQuantity(unit: HKUnit.gramUnit(with: .kilo), doubleValue: weight)
        let weightSample = HKQuantitySample(type: weightType, quantity: weightQuantity, start: date, end: date)
        
        healthStore.save(weightSample) { (success, error) in
            if !success { self.logger.error("Error saving weight to HealthKit: \(error?.localizedDescription ?? "Unknown error")") }
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
    
    // 5. Write a new Waist Measurement
    // 5. Write a new Waist Measurement
        func saveWaistMeasurement(_ waist: Double, date: Date, completion: @escaping (Bool, Error?) -> Void) {
            #if canImport(HealthKit)
            if #available(iOS 16.0, *) {
                guard let waistType = HKObjectType.quantityType(forIdentifier: .waistCircumference) else {
                    completion(false, nil); return
                }
                
                let waistQuantity = HKQuantity(unit: HKUnit.meterUnit(with: .centi), doubleValue: waist)
                let waistSample = HKQuantitySample(type: waistType, quantity: waistQuantity, start: date, end: date)
                
                // --- THIS IS THE FIX ---
                // The argument label is 'withCompletion', not 'completion'
                healthStore.save(waistSample, withCompletion: completion)
                // --- END OF FIX ---
            } else {
                completion(false, nil)
            }
            #else
            completion(false, nil)
            #endif
        }
    
    // 6. Read Today's Distance
    func readTodayDistance(completion: @escaping (Double?, Error?) -> Void) {
        guard let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            completion(nil, nil); return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            let value = result?.sumQuantity()?.doubleValue(for: HKUnit.meter())
            DispatchQueue.main.async {
                completion(value, error)
            }
        }
        healthStore.execute(query)
    }
    
    // 7. Read Today's Exercise Time
    func readTodayExerciseTime(completion: @escaping (Double?, Error?) -> Void) {
        guard let exerciseType = HKObjectType.quantityType(forIdentifier: .appleExerciseTime) else {
            completion(nil, nil); return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: exerciseType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            let value = result?.sumQuantity()?.doubleValue(for: HKUnit.minute())
            DispatchQueue.main.async {
                completion(value, error)
            }
        }
        healthStore.execute(query)
    }
    
    // 8. Read Latest Heart Rate
    func readLatestHeartRate(completion: @escaping (Double?, Error?) -> Void) {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            completion(nil, nil); return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, results, error in
            guard let sample = results?.first as? HKQuantitySample else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let value = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            DispatchQueue.main.async {
                completion(value, error)
            }
        }
        healthStore.execute(query)
    }
    
    // 9. Read Weekly Step Average
    func readWeeklyStepAverage(completion: @escaping (Double?, Error?) -> Void) {
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            completion(nil, nil); return
        }

        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -7, to: endDate) else {
            completion(nil, nil); return
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let sum = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let average = sum / 7.0
            DispatchQueue.main.async {
                completion(average, error)
            }
        }
        healthStore.execute(query)
    }

    // MARK: - Apple Watch Specific Data

    // 10. Read Resting Heart Rate (Apple Watch)
    func readRestingHeartRate(completion: @escaping (Double?, Error?) -> Void) {
        guard let restingHRType = HKObjectType.quantityType(forIdentifier: .restingHeartRate) else {
            completion(nil, nil); return
        }

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: restingHRType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, results, error in
            guard let sample = results?.first as? HKQuantitySample else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }

            let value = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            DispatchQueue.main.async { completion(value, error) }
        }
        healthStore.execute(query)
    }

    // 11. Read Heart Rate Variability (HRV) - Apple Watch
    func readHeartRateVariability(completion: @escaping (Double?, Error?) -> Void) {
        guard let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            completion(nil, nil); return
        }

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: hrvType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, results, error in
            guard let sample = results?.first as? HKQuantitySample else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }

            let value = sample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
            DispatchQueue.main.async { completion(value, error) }
        }
        healthStore.execute(query)
    }

    // 12. Read VO2 Max - Apple Watch
    func readVO2Max(completion: @escaping (Double?, Error?) -> Void) {
        guard let vo2Type = HKObjectType.quantityType(forIdentifier: .vo2Max) else {
            completion(nil, nil); return
        }

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: vo2Type, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, results, error in
            guard let sample = results?.first as? HKQuantitySample else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }

            // VO2 Max in mL/kg/min
            let unit = HKUnit.literUnit(with: .milli).unitDivided(by: HKUnit.gramUnit(with: .kilo).unitMultiplied(by: HKUnit.minute()))
            let value = sample.quantity.doubleValue(for: unit)
            DispatchQueue.main.async { completion(value, error) }
        }
        healthStore.execute(query)
    }

    // 13. Read Blood Oxygen Saturation - Apple Watch
    func readOxygenSaturation(completion: @escaping (Double?, Error?) -> Void) {
        guard let oxygenType = HKObjectType.quantityType(forIdentifier: .oxygenSaturation) else {
            completion(nil, nil); return
        }

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: oxygenType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, results, error in
            guard let sample = results?.first as? HKQuantitySample else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }

            let value = sample.quantity.doubleValue(for: HKUnit.percent()) * 100 // Convert to percentage
            DispatchQueue.main.async { completion(value, error) }
        }
        healthStore.execute(query)
    }

    // 14. Read Resting/Basal Energy Burned
    func readTodayRestingEnergy(completion: @escaping (Double?, Error?) -> Void) {
        guard let energyType = HKObjectType.quantityType(forIdentifier: .basalEnergyBurned) else {
            completion(nil, nil); return
        }

        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: energyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            let value = result?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie())
            DispatchQueue.main.async { completion(value, error) }
        }
        healthStore.execute(query)
    }

    // 15. Read Stand Time - Apple Watch
    func readTodayStandTime(completion: @escaping (Double?, Error?) -> Void) {
        guard let standType = HKObjectType.quantityType(forIdentifier: .appleStandTime) else {
            completion(nil, nil); return
        }

        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: standType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            let value = result?.sumQuantity()?.doubleValue(for: HKUnit.minute())
            DispatchQueue.main.async { completion(value, error) }
        }
        healthStore.execute(query)
    }

    // 16. Read Flights Climbed
    func readTodayFlightsClimbed(completion: @escaping (Double?, Error?) -> Void) {
        guard let flightsType = HKObjectType.quantityType(forIdentifier: .flightsClimbed) else {
            completion(nil, nil); return
        }

        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: flightsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            let value = result?.sumQuantity()?.doubleValue(for: HKUnit.count())
            DispatchQueue.main.async { completion(value, error) }
        }
        healthStore.execute(query)
    }

    // 17. Read Walking Speed
    func readLatestWalkingSpeed(completion: @escaping (Double?, Error?) -> Void) {
        guard let speedType = HKObjectType.quantityType(forIdentifier: .walkingSpeed) else {
            completion(nil, nil); return
        }

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: speedType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, results, error in
            guard let sample = results?.first as? HKQuantitySample else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }

            // Convert m/s to km/h
            let metersPerSecond = sample.quantity.doubleValue(for: HKUnit.meter().unitDivided(by: HKUnit.second()))
            let kmPerHour = metersPerSecond * 3.6
            DispatchQueue.main.async { completion(kmPerHour, error) }
        }
        healthStore.execute(query)
    }

    // 18. Read Cycling Distance
    func readTodayCyclingDistance(completion: @escaping (Double?, Error?) -> Void) {
        guard let distanceType = HKObjectType.quantityType(forIdentifier: .distanceCycling) else {
            completion(nil, nil); return
        }

        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            let value = result?.sumQuantity()?.doubleValue(for: HKUnit.meter())
            DispatchQueue.main.async { completion(value, error) }
        }
        healthStore.execute(query)
    }

    // 19. Read Activity Summary (Apple Watch Rings)
    func readTodayActivitySummary(completion: @escaping (HKActivitySummary?, Error?) -> Void) {
        let calendar = Calendar.current
        let now = Date()

        var dateComponents = calendar.dateComponents([.year, .month, .day], from: now)
        dateComponents.calendar = calendar

        let predicate = HKQuery.predicateForActivitySummary(with: dateComponents)
        let query = HKActivitySummaryQuery(predicate: predicate) { _, summaries, error in
            DispatchQueue.main.async {
                completion(summaries?.first, error)
            }
        }
        healthStore.execute(query)
    }

    // MARK: - Async/Await API (Modern Swift)

    /// Fetch today's health data using async/await
    @MainActor
    func fetchTodayHealthDataAsync() async -> HealthData {
        var healthData = HealthData()

        await withTaskGroup(of: Void.self) { group in
            group.addTask { @MainActor in
                healthData.steps = await self.readTodayStepsAsync()
            }
            group.addTask { @MainActor in
                healthData.activeCalories = await self.readTodayActiveEnergyAsync()
            }
            group.addTask { @MainActor in
                healthData.restingCalories = await self.readTodayRestingEnergyAsync()
            }
            group.addTask { @MainActor in
                healthData.distance = await self.readTodayDistanceAsync()
            }
            group.addTask { @MainActor in
                healthData.cyclingDistance = await self.readTodayCyclingDistanceAsync()
            }
            group.addTask { @MainActor in
                healthData.exerciseMinutes = await self.readTodayExerciseTimeAsync()
            }
            group.addTask { @MainActor in
                healthData.standMinutes = await self.readTodayStandTimeAsync()
            }
            group.addTask { @MainActor in
                healthData.heartRate = await self.readLatestHeartRateAsync()
            }
            group.addTask { @MainActor in
                healthData.restingHeartRate = await self.readRestingHeartRateAsync()
            }
            group.addTask { @MainActor in
                healthData.heartRateVariability = await self.readHeartRateVariabilityAsync()
            }
            group.addTask { @MainActor in
                healthData.vo2Max = await self.readVO2MaxAsync()
            }
            group.addTask { @MainActor in
                healthData.oxygenSaturation = await self.readOxygenSaturationAsync()
            }
            group.addTask { @MainActor in
                healthData.flightsClimbed = await self.readTodayFlightsClimbedAsync()
            }
            group.addTask { @MainActor in
                healthData.walkingSpeed = await self.readLatestWalkingSpeedAsync()
            }
            group.addTask { @MainActor in
                if let summary = await self.readTodayActivitySummaryAsync() {
                    healthData.moveGoal = summary.activeEnergyBurnedGoal.doubleValue(for: .kilocalorie())
                    healthData.moveProgress = summary.activeEnergyBurned.doubleValue(for: .kilocalorie())
                    healthData.exerciseGoal = summary.appleExerciseTimeGoal.doubleValue(for: .minute())
                    healthData.exerciseProgress = summary.appleExerciseTime.doubleValue(for: .minute())
                    healthData.standGoal = summary.appleStandHoursGoal.doubleValue(for: .count())
                    healthData.standProgress = summary.appleStandHours.doubleValue(for: .count())
                }
            }
        }

        return healthData
    }

    // Async wrapper methods
    func readTodayStepsAsync() async -> Int? {
        await withCheckedContinuation { continuation in
            readTodaySteps { value, _ in
                continuation.resume(returning: value.map { Int($0) })
            }
        }
    }

    func readTodayActiveEnergyAsync() async -> Int? {
        await withCheckedContinuation { continuation in
            readTodayActiveEnergy { value, _ in
                continuation.resume(returning: value.map { Int($0) })
            }
        }
    }

    func readTodayRestingEnergyAsync() async -> Int? {
        await withCheckedContinuation { continuation in
            readTodayRestingEnergy { value, _ in
                continuation.resume(returning: value.map { Int($0) })
            }
        }
    }

    func readTodayDistanceAsync() async -> Double? {
        await withCheckedContinuation { continuation in
            readTodayDistance { value, _ in
                continuation.resume(returning: value.map { $0 / 1000.0 }) // km
            }
        }
    }

    func readTodayCyclingDistanceAsync() async -> Double? {
        await withCheckedContinuation { continuation in
            readTodayCyclingDistance { value, _ in
                continuation.resume(returning: value.map { $0 / 1000.0 }) // km
            }
        }
    }

    func readTodayExerciseTimeAsync() async -> Int? {
        await withCheckedContinuation { continuation in
            readTodayExerciseTime { value, _ in
                continuation.resume(returning: value.map { Int($0) })
            }
        }
    }

    func readTodayStandTimeAsync() async -> Int? {
        await withCheckedContinuation { continuation in
            readTodayStandTime { value, _ in
                continuation.resume(returning: value.map { Int($0) })
            }
        }
    }

    func readLatestHeartRateAsync() async -> Int? {
        await withCheckedContinuation { continuation in
            readLatestHeartRate { value, _ in
                continuation.resume(returning: value.map { Int($0) })
            }
        }
    }

    func readRestingHeartRateAsync() async -> Int? {
        await withCheckedContinuation { continuation in
            readRestingHeartRate { value, _ in
                continuation.resume(returning: value.map { Int($0) })
            }
        }
    }

    func readHeartRateVariabilityAsync() async -> Double? {
        await withCheckedContinuation { continuation in
            readHeartRateVariability { value, _ in
                continuation.resume(returning: value)
            }
        }
    }

    func readVO2MaxAsync() async -> Double? {
        await withCheckedContinuation { continuation in
            readVO2Max { value, _ in
                continuation.resume(returning: value)
            }
        }
    }

    func readOxygenSaturationAsync() async -> Double? {
        await withCheckedContinuation { continuation in
            readOxygenSaturation { value, _ in
                continuation.resume(returning: value)
            }
        }
    }

    func readTodayFlightsClimbedAsync() async -> Int? {
        await withCheckedContinuation { continuation in
            readTodayFlightsClimbed { value, _ in
                continuation.resume(returning: value.map { Int($0) })
            }
        }
    }

    func readLatestWalkingSpeedAsync() async -> Double? {
        await withCheckedContinuation { continuation in
            readLatestWalkingSpeed { value, _ in
                continuation.resume(returning: value)
            }
        }
    }

    func readTodayActivitySummaryAsync() async -> HKActivitySummary? {
        await withCheckedContinuation { continuation in
            readTodayActivitySummary { summary, _ in
                continuation.resume(returning: summary)
            }
        }
    }

    /// Request authorization using async/await
    func requestAuthorizationAsync() async -> Bool {
        await withCheckedContinuation { continuation in
            requestAuthorization { success, _ in
                continuation.resume(returning: success)
            }
        }
    }

    // 20. Legacy Fetch All Today's Health Data (callback-based)
    func fetchTodayHealthData(completion: @escaping (HealthData) -> Void) {
        var healthData = HealthData()
        let group = DispatchGroup()

        group.enter()
        readTodaySteps { steps, _ in
            healthData.steps = steps.map { Int($0) }
            group.leave()
        }

        group.enter()
        readTodayActiveEnergy { calories, _ in
            healthData.activeCalories = calories.map { Int($0) }
            group.leave()
        }

        group.enter()
        readTodayRestingEnergy { calories, _ in
            healthData.restingCalories = calories.map { Int($0) }
            group.leave()
        }

        group.enter()
        readTodayDistance { distance, _ in
            healthData.distance = distance.map { $0 / 1000.0 } // Convert to km
            group.leave()
        }

        group.enter()
        readTodayExerciseTime { minutes, _ in
            healthData.exerciseMinutes = minutes.map { Int($0) }
            group.leave()
        }

        group.enter()
        readLatestHeartRate { heartRate, _ in
            healthData.heartRate = heartRate.map { Int($0) }
            group.leave()
        }

        group.enter()
        readRestingHeartRate { hr, _ in
            healthData.restingHeartRate = hr.map { Int($0) }
            group.leave()
        }

        group.enter()
        readVO2Max { vo2, _ in
            healthData.vo2Max = vo2
            group.leave()
        }

        group.enter()
        readTodayFlightsClimbed { flights, _ in
            healthData.flightsClimbed = flights.map { Int($0) }
            group.leave()
        }

        group.notify(queue: .main) {
            completion(healthData)
        }
    }
}

// MARK: - Health Data Model
public struct HealthData {
    public var steps: Int?
    public var activeCalories: Int?
    public var restingCalories: Int?
    public var totalCalories: Int? { // Computed total
        guard let active = activeCalories, let resting = restingCalories else { return activeCalories }
        return active + resting
    }
    public var distance: Double? // in kilometers
    public var cyclingDistance: Double? // in kilometers
    public var exerciseMinutes: Int?
    public var standMinutes: Int? // Apple Watch stand time
    public var heartRate: Int?
    public var restingHeartRate: Int?
    public var heartRateVariability: Double? // HRV in ms
    public var vo2Max: Double? // mL/kg/min
    public var oxygenSaturation: Double? // percentage 0-100
    public var respiratoryRate: Double? // breaths per minute
    public var flightsClimbed: Int?
    public var walkingSpeed: Double? // km/h
    public var stepLength: Double? // cm
    public var doubleSupportPercentage: Double? // walking balance %

    // Activity Ring data (Apple Watch)
    public var moveGoal: Double?
    public var moveProgress: Double?
    public var exerciseGoal: Double?
    public var exerciseProgress: Double?
    public var standGoal: Double?
    public var standProgress: Double?

    public init(
        steps: Int? = 0,
        activeCalories: Int? = 0,
        restingCalories: Int? = nil,
        distance: Double? = 0,
        cyclingDistance: Double? = nil,
        exerciseMinutes: Int? = 0,
        standMinutes: Int? = nil,
        heartRate: Int? = nil,
        restingHeartRate: Int? = nil,
        heartRateVariability: Double? = nil,
        vo2Max: Double? = nil,
        oxygenSaturation: Double? = nil,
        respiratoryRate: Double? = nil,
        flightsClimbed: Int? = nil,
        walkingSpeed: Double? = nil,
        stepLength: Double? = nil,
        doubleSupportPercentage: Double? = nil,
        moveGoal: Double? = nil,
        moveProgress: Double? = nil,
        exerciseGoal: Double? = nil,
        exerciseProgress: Double? = nil,
        standGoal: Double? = nil,
        standProgress: Double? = nil
    ) {
        self.steps = steps
        self.activeCalories = activeCalories
        self.restingCalories = restingCalories
        self.distance = distance
        self.cyclingDistance = cyclingDistance
        self.exerciseMinutes = exerciseMinutes
        self.standMinutes = standMinutes
        self.heartRate = heartRate
        self.restingHeartRate = restingHeartRate
        self.heartRateVariability = heartRateVariability
        self.vo2Max = vo2Max
        self.oxygenSaturation = oxygenSaturation
        self.respiratoryRate = respiratoryRate
        self.flightsClimbed = flightsClimbed
        self.walkingSpeed = walkingSpeed
        self.stepLength = stepLength
        self.doubleSupportPercentage = doubleSupportPercentage
        self.moveGoal = moveGoal
        self.moveProgress = moveProgress
        self.exerciseGoal = exerciseGoal
        self.exerciseProgress = exerciseProgress
        self.standGoal = standGoal
        self.standProgress = standProgress
    }
}


