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
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Dipodi", category: "HealthKitManager")
    
    private let healthStore = HKHealthStore()
    
    // Define the data types we want to read and write
    private var readTypes: Set<HKObjectType> {
        return Set([
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!, // Weight
            HKObjectType.quantityType(forIdentifier: .height)!,
            HKObjectType.quantityType(forIdentifier: .waistCircumference)!,
            HKObjectType.quantityType(forIdentifier: .vo2Max)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .restingHeartRate)!
        ])
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
            if !success { self.logger.error("Error saving weight to HealthKit: \(error!)") }
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
    
    // 10. Fetch All Today's Health Data
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
        
        group.notify(queue: .main) {
            completion(healthData)
        }
    }
}

// MARK: - Health Data Model
public struct HealthData {
    public var steps: Int?
    public var activeCalories: Int?
    public var distance: Double? // in kilometers
    public var exerciseMinutes: Int?
    public var heartRate: Int?
    
    public init(steps: Int? = 0, activeCalories: Int? = 0, distance: Double? = 0, exerciseMinutes: Int? = 0, heartRate: Int? = nil) {
        self.steps = steps
        self.activeCalories = activeCalories
        self.distance = distance
        self.exerciseMinutes = exerciseMinutes
        self.heartRate = heartRate
    }
}


