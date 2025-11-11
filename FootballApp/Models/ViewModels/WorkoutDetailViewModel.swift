//
//  WorkoutDetailViewModel.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 14/11/2025.
//

import Foundation
import Combine
import os.log
import SwiftUI
import AVFoundation

// Define the state enum here
enum WorkoutState: Equatable {
    case idle, warmup, workout, rest, cooldown, finished
}

@MainActor
class WorkoutDetailViewModel: ObservableObject {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Dipodi", category: "WorkoutDetailVM")

    // --- Published State ---
    @Published var session: WorkoutSession
    @Published var currentState: WorkoutState = .idle
    @Published var currentExerciseIndex: Int = 0
    @Published var currentSet: Int = 1
    @Published var currentRep: Int = 1
    @Published var timerValue: Int = 0
    @Published var totalTime: Int = 0
    
    private var timer: AnyCancellable?

    // --- Computed Properties ---
    var totalSets: Int {
        guard let setsString = currentExercise?.sets else { return 1 }
        return Int(setsString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) ?? 1
    }

    var currentExercise: WorkoutExercise? {
        guard let exercises = session.exercises, exercises.indices.contains(currentExerciseIndex) else { return nil }
        return exercises[currentExerciseIndex]
    }
    
    var nextExercise: WorkoutExercise? {
        guard let exercises = session.exercises, exercises.indices.contains(currentExerciseIndex + 1) else { return nil }
        return exercises[currentExerciseIndex + 1]
    }
    
    var totalExercisesInSession: Int {
        session.exercises?.count ?? 0
    }

    init(session: WorkoutSession) {
        self.session = session
        // FIX: Ensuring computed properties are accessed consistently in debug context
        let exerciseCount = self.session.exercises?.count ?? 0
        logger.debug("Init VM; session=\(session.id) theme=\(session.theme) exercises=\(exerciseCount)")
    }

    // MARK: - Core Flow
    
    func next() {
        self.logger.debug("next() called; state=\(String(describing: self.currentState))")
        stopTimer()

        switch currentState {
        case .idle:
            self.currentState = .warmup
            self.startTimer(duration: self.parseTime(self.session.warmup ?? "5 min"))
            
        case .warmup:
            self.currentState = .workout
            self.currentExerciseIndex = 0
            self.currentSet = 1
            self.currentRep = 1

        case .rest:
            if self.currentSet < self.totalSets {
                self.currentSet += 1
                self.currentState = .workout
            } else if (self.currentExerciseIndex + 1) < self.totalExercisesInSession {
                self.currentExerciseIndex += 1
                self.currentSet = 1
                self.currentState = .workout
            } else {
                self.currentState = .cooldown
                self.startTimer(duration: self.parseTime(self.session.finisher ?? "5 min"))
            }

        case .workout:
            break
            
        case .cooldown:
            self.currentState = .finished
        
        case .finished:
            self.currentState = .idle
        }
    }
    
    func completeSet() {
        self.logger.info("Set \(self.currentSet)/\(self.totalSets) completed. Entering rest.")
        self.currentState = .rest
        let recoveryTime = parseRecoveryTime(currentExercise?.recovery ?? "60s")
        self.startTimer(duration: recoveryTime)
        self.currentRep = 1
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func skipRest() {
        self.logger.info("Rest phase skipped.")
        stopTimer()
        self.next()
    }
    
    func skipExercise() {
        self.logger.info("Exercise skipped. Advancing to next or cooldown.")
        self.currentSet = self.totalSets
        stopTimer()
        self.next()
    }

    func skipPhase() {
        self.logger.info("Current phase skipped.")
        stopTimer()
        if currentState == .warmup {
            currentState = .workout
            currentExerciseIndex = 0
            currentSet = 1
        } else if currentState == .cooldown {
            currentState = .finished
        } else {
            self.next()
        }
    }

    // MARK: - Timer Logic

    private func startTimer(duration: Int) {
        totalTime = duration
        timerValue = duration
        
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            guard let self = self else { return }
            if self.timerValue > 0 {
                self.timerValue -= 1
            } else {
                self.logger.info("Timer finished. Advancing state.")
                self.stopTimer()
                self.next()
            }
        }
    }

    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }

    // MARK: - Parsing Helpers
    
    private func parseTime(_ duration: String) -> Int {
        let components = duration.lowercased().components(separatedBy: CharacterSet.decimalDigits.inverted).filter { !$0.isEmpty }
        if duration.contains("min"), let minutes = Int(components.first ?? "5") {
            return minutes * 60
        }
        if let seconds = Int(components.first ?? "300") {
             return seconds
        }
        return 300
    }
    
    private func parseRecoveryTime(_ recovery: String) -> Int {
        let components = recovery.lowercased().components(separatedBy: CharacterSet.decimalDigits.inverted).filter { !$0.isEmpty }
        
        if recovery.lowercased().contains("min"), let minutes = Int(components.first ?? "1") {
            return minutes * 60
        }
        
        if let seconds = Int(components.first ?? "60") {
             return seconds
        }
        return 60
    }
}
