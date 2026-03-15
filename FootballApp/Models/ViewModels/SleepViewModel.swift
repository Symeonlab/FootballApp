//
//  SleepViewModel.swift
//  FootballApp
//
//  ViewModel for managing sleep protocols, chronotypes, and bedtime calculations
//

import Foundation
import Combine
import os

@MainActor
class SleepViewModel: ObservableObject {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "DiPODDI", category: "SleepViewModel")

    // MARK: - Published Properties
    @Published var protocols: [SleepProtocol] = []
    @Published var chronotypes: [Chronotype] = []
    @Published var sleepCalculation: SleepCalculation?
    @Published var selectedChronotype: Chronotype?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Private Properties
    private let apiService = APIService.shared

    // MARK: - Fetch Methods

    func fetchProtocols(category: String? = nil) async {
        isLoading = true
        errorMessage = nil
        do {
            var endpoint = APIEndpoints.sleepProtocols
            if let category = category {
                endpoint += "?category=\(category)"
            }
            let response: GenericAPIResponse<[SleepProtocol]> = try await apiService.request(endpoint: endpoint)
            self.protocols = response.data
            logger.info("Fetched \(self.protocols.count) sleep protocols")
        } catch {
            logger.error("Failed to fetch sleep protocols: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func fetchChronotypes() async {
        do {
            let response: GenericAPIResponse<[Chronotype]> = try await apiService.request(endpoint: APIEndpoints.sleepChronotypes)
            self.chronotypes = response.data
            // Auto-select first chronotype
            if selectedChronotype == nil {
                selectedChronotype = response.data.first
            }
            logger.info("Fetched \(self.chronotypes.count) chronotypes")
        } catch {
            logger.error("Failed to fetch chronotypes: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }

    func calculateBedtime(wakeTime: String, cycles: Int = 5) async {
        do {
            let endpoint = "\(APIEndpoints.sleepCalculate)?wake_time=\(wakeTime)&cycles=\(cycles)"
            let response: GenericAPIResponse<SleepCalculation> = try await apiService.request(endpoint: endpoint)
            self.sleepCalculation = response.data
            logger.info("Calculated bedtime: \(response.data.recommendedBedtime)")
        } catch {
            logger.error("Failed to calculate bedtime: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }
}
